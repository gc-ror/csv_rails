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
    def csv(objects:, encoding: 'Windows-31J', fields: nil, force_quotes: true, headers: nil, model_class: nil)
      if fields.present? && model_class.present?
        headers ||= fields.map { |field| model_class.human_attribute_name field }
      end

      CSV.generate force_quotes: force_quotes do |csv|
        csv << headers if headers.present?

        objects&.each do |object|
          csv << (fields.present? ? fields.map { |field| object.send field } : (yield object))
        end
      end.encode(encoding, undef: :replace)
    end
  end
end
