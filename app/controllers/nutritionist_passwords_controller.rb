class NutritionistPasswordsController < ApplicationController

  def forgot
    if params[:email].blank? # check if email is present
      return render json: {error: 'Email non présent'}
    end

    @nutritionist = Nutritionist.find_by(email: params[:email]) # if present find nutritionist by email

    if @nutritionist.present?
      @nutritionist.generate_password_token! #generate pass token
      NutritionistMailer.reset_password_email(@nutritionist).deliver_now   
      render json: {status: 'ok'}, status: :ok
    else
      render json: {error: ['Email non trouvé. Vérifiez puis recommencez']}, status: :not_found
    end
  end

  def reset
    token = params[:token].to_s

    if params[:email].blank?
      return render json: {error: 'Token non présent'}
    end

    nutritionist = Nutritionist.find_by(reset_password_token: token)

    if nutritionist.present? && nutritionist.password_token_valid?
      if nutritionist.reset_password!(params[:password])
        render json: {status: 'ok'}, status: :ok
      else
        render json: {error: nutritionist.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {error:  ['Lien invalide ou expiré. Regénerez un nouveau lien.']}, status: :not_found
    end
  end
end