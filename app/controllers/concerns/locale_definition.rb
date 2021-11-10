module LocaleDefinition
  extend ActiveSupport::Concern

  AVAILABLE_LOCALES = {
    'en' => 'English',
    'es' => 'Español',
    'de' => 'Deutsche',
    'it' => 'Italiano',
    'fr' => 'Français'
  }

  included do
    before_action :set_locale, if: -> { cookies['locale'] }

    private

    def set_locale
      primary_locale = set_primary_language.present? ? set_primary_language[0..1].to_sym : I18n.default_locale
      cookies_locale = cookies['locale'].present? ? cookies['locale'][0..1].to_sym : I18n.default_locale

      I18n.locale = cookies_locale != primary_locale ? cookies_locale : primary_locale
    end

    def set_primary_language
      current_app.selected_languages.detect { |l| l.include?('_primary') }
    end
  end
end
