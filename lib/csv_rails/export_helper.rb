# frozen_string_literal: true

require 'csv'

module CsvRails
  #
  # CSVエクスポートヘルパー
  #
  module ExportHelper
    #
    # CSV形式で出力します。
    #
    # @param [Enumerable<ApplicationRecord>] objects 出力対象オブジェクト
    # @param [String] encoding 文字列エンコーディング(Windows-31J)
    # @param [Array<Symbol>] fields フィールドリスト
    # @param [Boolean] force_quotes クオートを強制
    # @param [Array<String>] headers ヘッダー項目リスト
    # @param [Class] model_class モデルクラス
    #
    # @return [String] CSV文字列
    #
    # noinspection RubyNilAnalysis, RubyResolve
    #
    def csv(objects:, encoding: 'Windows-31J', fields: nil, extended_fields: nil, force_quotes: true, headers: nil, model_class: nil)
      if headers.blank?
        headers = [
          (fields.map { |field| model_class.human_attribute_name field } if fields.present? && model_class.present?),
          (extended_fields.map { |name, _attr, _key| name } if extended_fields.present?)
        ].compact.reduce(&:concat)
      end

      CSV.generate force_quotes: force_quotes do |csv|
        csv << headers if headers.present?

        objects&.each do |object|
          row = if block_given?
                  yield object
                else
                  headers = [
                    (fields.map { |field| object.send field } if fields.present?),
                    (extended_fields.map { |_name, attr, key| object.send(attr)[key] } if extended_fields.present?)
                  ].compact.reduce(&:concat)
                end
          csv << row
        end
      end.encode(encoding, undef: :replace)
    end
  end
end
