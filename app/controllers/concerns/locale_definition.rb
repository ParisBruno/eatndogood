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
      primary = set_primary_language
      I18n.locale = cookies['locale'] != primary ? cookies['locale'][0..1].to_sym || I18n.default_locale : primary[0..1].to_sym
    end

    def set_primary_language
      current_app.selected_languages.detect { |l| l.include?('_primary') }
    end
  end
end
