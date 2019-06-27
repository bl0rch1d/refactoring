# frozen_string_literal: true

module ValidationHelper
  private

  def validate_capitalized_string(value:, field:)
    I18n.t("ACCOUNT.ERRORS.BAD_#{field.upcase}") unless value.match?(/\A[A-Z]/)
  end

  def validate_length_range(value:, field:, range:)
    return I18n.t("ACCOUNT.ERRORS.#{field.upcase}.LONG") if value.length > range.max

    I18n.t("ACCOUNT.ERRORS.#{field.upcase}.SHORT") if value.length < range.min
  end

  def validate_emptyness(value:, field:)
    I18n.t("ACCOUNT.ERRORS.#{field.upcase}.EMPTY") if value.empty?
  end

  def validate_integer(value:, field:)
    I18n.t("ACCOUNT.ERRORS.#{field.upcase}.NOT_A_NUMBER") unless value.is_a? Integer
  end

  def validate_integer_range(value:, field:, range:)
    return I18n.t("ACCOUNT.ERRORS.#{field.upcase}.SMALL") unless value >= range.min

    I18n.t("ACCOUNT.ERRORS.#{field.upcase}.BIG") unless value <= range.max
  end

  def validate_account_uniqueness(value)
    I18n.t('ACCOUNT.ERRORS.ACCOUNT_EXISTS') if accounts.map(&:login).include? value
  end
end
