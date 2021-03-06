# frozen_string_literal: true

require 'csv'
require 'active_support/concern'

module CsvRails
  #
  # CSVのパーズ機能をモデルに追加します。
  # CSVの読み取りを行いたいモデルに対してクラスメソッドとして機能を追加します。
  #
  module Parser
    extend ActiveSupport::Concern

    #
    # フォーマットが正しくない場合のエラー
    #
    class FormatInvalid < StandardError
    end

    included do
      attr_accessor :line_no
    end

    class_methods do
      #
      # CSVファイルをパーズしてハッシュ化します。
      # header の文字列は、ModelClass#human_attribute_name で取得できる値(locale.ja.ymlで定義)を使用します。
      #
      # @param [File] input 読み取り元(文字列 or read メソッドを持ったオブジェクト)
      # @param [Array<Symbol>] fields 読み取り対象フィールド
      # @param [Array<Symbol>] required_fields 必須のフィールド
      # @param [String] encoding CSVファイルのエンコーディング
      #
      # @yield CSVファイルの行ごとの処理
      # @yieldparam [Hash] CSVファイルの行をハッシュ化したもの
      #
      # @raise [CsvParser::FormatInvalid] required_fieldsで指定したフィールドがなかった場合
      # @raise [CSV::MalformedCSVError]
      #
      # @return [Array<Hash>] 読み取ったフィアルのハッシュの配列(ブロックが指定されていない場合)
      #
      def parse_csv(input, fields:, encoding: 'Windows-31J', required_fields: [], extended_fields: [])
        if input.respond_to? :read
          input = if input.is_a? ActionDispatch::Http::UploadedFile
                    input = input.read
                    input.force_encoding('Windows-31J')
                    input.encode(invalid: :replace, undef: :replace)
                  else
                    input.read(encoding: encoding)
                  end
        end

        csv = CSV.parse(input, headers: true, skip_blanks: true)
        map = fields.map { |field| [human_attribute_name(field), field] }.select { |from, _to| csv.headers.include? from }
        map2 = extended_fields.select { |name, _attr, _key| csv.headers.include? name }
        uploaded_fields = map.map(&:last).to_set
        raise FormatInvalid unless required_fields.all? { |field| uploaded_fields.include? field }

        results = csv.map do |row|
          [
            map.map do |from, to|
              [to, row[from]]
            end,
            map2.map do |name, attr, key|
              [attr, key, row[name]]
            end.group_by do |attr, _key, _value|
              attr
            end.map do |attr, values|
              [attr, values.map { |_attr, key, value| [key, value] }.to_h]
            end
          ].inject(&:concat).to_h
        end

        if block_given?
          results.each { |result| yield result }
          nil
        else
          results
        end
      end
    end
  end
end