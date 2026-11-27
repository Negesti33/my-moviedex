class PreferencesController < ApplicationController
  def edit
  end

  def update
    # apres le sign up on se redirige sur le formulaire de onboarding
    # en updatant les préférences avec les params
    if current_user.update(params.require(:user).permit(:preferences))
      redirect_to root_path, notice: "🍿Vos préférences ont bien été sauvegardées?🍿"
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
