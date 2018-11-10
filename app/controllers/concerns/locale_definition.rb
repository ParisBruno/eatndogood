module LocaleDefinition
  extend ActiveSupport::Concern

  included do
    before_action :set_locale, if: -> { cookies['locale'] }

    private

    def set_locale
      I18n.locale = cookies['locale'] || I18n.default_locale
    end
  end
end
