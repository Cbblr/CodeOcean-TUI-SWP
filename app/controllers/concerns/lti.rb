require 'oauth/request_proxy/rack_request'

module Lti
  extend ActiveSupport::Concern
  include LtiHelper

  MAXIMUM_SCORE = 1
  MAXIMUM_SESSION_AGE = 60.minutes
  SESSION_PARAMETERS = %w(launch_presentation_return_url lis_outcome_service_url lis_result_sourcedid)

  def build_tool_provider(options = {})
    if options[:consumer] && options[:parameters]
      IMS::LTI::ToolProvider.new(options[:consumer].oauth_key, options[:consumer].oauth_secret, options[:parameters])
    end
  end
  private :build_tool_provider

  # exercise_id.nil? ==> the user has logged out. All session data is to be destroyed
  # exercise_id.exists? ==> the user has submitted the results of an exercise to the consumer.
  # Only the lti_parameters are deleted.
  def clear_lti_session_data(exercise_id = nil, user_id = nil, consumer_id = nil)
    if (exercise_id.nil?)
      session.delete(:consumer_id)
      session.delete(:external_user_id)
      session.delete(:embed_options)
    else
      LtiParameter.where(consumers_id: consumer_id,
                         external_users_id: user_id,
                         exercises_id: exercise_id).destroy_all
    end
  end
  private :clear_lti_session_data

  def consumer_return_url(provider, options = {})
    consumer_return_url = provider.try(:launch_presentation_return_url) || params[:launch_presentation_return_url]
    consumer_return_url += "?#{options.to_query}" if consumer_return_url && options.present?
    consumer_return_url
  end

  def external_user_email(provider)
    provider.lis_person_contact_email_primary
  end
  private :external_user_email

  def external_user_name(provider)
    # save person_name_full if supplied. this is the display_name, if it is set.
    # else only save the firstname, we don't want lastnames (family names)
    if provider.lis_person_name_full
      provider.lis_person_name_full
    else
      provider.lis_person_name_given
    end
  end
  private :external_user_name

  def external_user_role(provider)
    result = 'learner'
    provider.roles.each do |role|
      case role.downcase
      when 'administrator'
        # We don't want anyone to get admin privileges through LTI
        result = 'teacher' if result == 'learner'
      when 'instructor'
        result = 'teacher' if result == 'learner'
      else # 'learner'
        next
      end
    end unless provider.roles.blank?
    result
  end

  def mooc_course
    # All Xikolo platforms set the custom_course to the course code
   params[:custom_course]
  end

  def refuse_lti_launch(options = {})
    return_to_consumer(lti_errorlog: options[:message], lti_errormsg: t('sessions.oauth.failure'))
  end
  private :refuse_lti_launch

  def require_oauth_parameters
    refuse_lti_launch(message: t('sessions.oauth.missing_parameters')) unless params[:oauth_consumer_key] && params[:oauth_signature]
  end
  private :require_oauth_parameters

  def require_unique_oauth_nonce
    refuse_lti_launch(message: t('sessions.oauth.used_nonce')) if NonceStore.has?(params[:oauth_nonce])
  end
  private :require_unique_oauth_nonce

  def require_valid_consumer_key
    @consumer = Consumer.find_by(oauth_key: params[:oauth_consumer_key])
    refuse_lti_launch(message: t('sessions.oauth.invalid_consumer')) unless @consumer
  end
  private :require_valid_consumer_key

  def require_valid_exercise_token
    proxy_exercise = ProxyExercise.find_by(token: params[:custom_token])
    unless proxy_exercise.nil?
      @exercise = proxy_exercise.get_matching_exercise(@current_user)
    else
      @exercise = Exercise.find_by(token: params[:custom_token])
    end
    refuse_lti_launch(message: t('sessions.oauth.invalid_exercise_token')) unless @exercise
  end
  private :require_valid_exercise_token

  def require_valid_oauth_signature
    @provider = build_tool_provider(consumer: @consumer, parameters: params)
    refuse_lti_launch(message: t('sessions.oauth.invalid_signature')) unless @provider.valid_request?(request)
  end
  private :require_valid_oauth_signature

  def return_to_consumer(options = {})
    consumer_return_url = @provider.try(:launch_presentation_return_url) || params[:launch_presentation_return_url]
    if consumer_return_url
      consumer_return_url += "?#{options.to_query}" if options.present?
      redirect_to(consumer_return_url)
    else
      flash[:danger] = options[:lti_errormsg]
      flash[:info] = options[:lti_msg]
      redirect_to(:root)
    end
  end
  private :return_to_consumer

  def send_score(exercise_id, score, user_id)
    ::NewRelic::Agent.add_custom_attributes({ score: score, session: session })
    fail(Error, "Score #{score} must be between 0 and #{MAXIMUM_SCORE}!") unless (0..MAXIMUM_SCORE).include?(score)

    if session[:consumer_id]
      lti_parameter = LtiParameter.where(consumers_id: session[:consumer_id],
                                         external_users_id: user_id,
                                         exercises_id: exercise_id).first

      consumer = Consumer.find_by(id: session[:consumer_id])
      provider = build_tool_provider(consumer: consumer, parameters: lti_parameter.lti_parameters)
    end

    if provider.nil?
      {status: 'error'}
    elsif provider.outcome_service?
      response = provider.post_replace_result!(score)
      {code: response.response_code, message: response.post_response.body, status: response.code_major}
    else
      {status: 'unsupported'}
    end
  end
  private :send_score

  def set_current_user
    @current_user = ExternalUser.find_or_create_by(consumer_id: @consumer.id, external_id: @provider.user_id)
    external_role = external_user_role(@provider)
    internal_role = @current_user.role
    internal_role != 'admin' ? desired_role = external_role : desired_role = internal_role
    # Update user with new information but change the role only if he is no admin user
    @current_user.update(email: external_user_email(@provider), name: external_user_name(@provider), role: desired_role)
  end
  private :set_current_user


  def set_study_group_membership
    if mooc_course
      group = StudyGroup.find_or_create_by(name: @provider.context_title, external_id: @provider.context_id, consumer: @consumer)
    else
      group = StudyGroup.find_or_create_by(external_id: @provider.resource_link_id, consumer: @consumer)
    end
    group.users |= [@current_user] # add current user if not already member of the group
    group.save
    session[:study_group_id] = group.id
  end

  def set_embedding_options
    @embed_options = {}
    [:hide_navbar,
     :hide_exercise_description,
     :disable_run,
     :disable_score,
     :disable_rfc,
     :disable_interventions,
     :hide_sidebar,
     :read_only,
     :hide_test_results,
     :disable_hints,
     :disable_download].each do |option|
      value = params["custom_embed_options_#{option}".to_sym] == 'true'
      # Optimize storage and save only those that are true, the session cookie is limited to 4KB
      @embed_options[option] = value if value.present?
    end
    session[:embed_options] = @embed_options
  end
  private :set_embedding_options

  def store_lti_session_data(options = {})
    lti_parameters = LtiParameter.find_or_create_by(consumers_id: options[:consumer].id,
                                                    external_users_id: @current_user.id,
                                                    exercises_id: @exercise.id)

    lti_parameters.lti_parameters = options[:parameters].slice(*SESSION_PARAMETERS).permit!.to_h
    lti_parameters.save!
    @lti_parameters = lti_parameters

    session[:consumer_id] = options[:consumer].id
    session[:external_user_id] = @current_user.id
  end
  private :store_lti_session_data

  def store_nonce(nonce)
    NonceStore.add(nonce)
  end
  private :store_nonce

  class Error < RuntimeError
  end
end
