module CsvLoader

  class Load

    attr_reader :limit, :file_path, :where_condition, :find_condition, :csv_string

    def initialize(file_path, model: nil, limit: nil, where: nil, find: nil, destroy_all: nil, delete_all: nil, csv_string: nil)
      @file_path = file_path
      if File.exists?("#{file_path}.zip")
        unzip(file_path) unless File.exists?(file_path)
      end
      @csv_string = csv_string
      @limit = limit
      @model = model
      @where_condition = where
      @find_condition = [*find]
      destroy_all(destroy_all)
      delete_all(delete_all)
      load_csv_into_model
    end

    private

    def unzip(file_path)
      base_name = File.basename(file_path)
      folder = File.dirname(file_path)
      system "cd #{folder}; unzip -qq -u #{base_name}.zip"
    end

    def load_csv_into_model
      current_row = {}
      csv.each do |row|
        current_row = row.to_hash
        next unless find(current_row)
        next unless where(current_row)
        model.create! clean_row(current_row)
      end
    rescue Exception, NameError => e
      puts "Possibly an unknown attribute! #{current_row}"
      raise e.inspect
    end

    def clean_row(row)
      row.each do |key, value|
        row[key] = nil if value == '\\N'
      end
      row
    end

    def csv
      if csv_string.nil?
        lines = process_limit if limit
        lines = open_csv unless limit
      end
      lines = csv_string unless csv_string.nil?
      CSV.parse(lines, :headers => true, :quote_char => '"')
    end

    def process_limit
      if limit.is_a?(Range)
        range = limit
        header = IO.readlines(file_path)[0]
        lines = IO.readlines(file_path)[range].unshift(header).join('')
      else
        lines = IO.readlines(file_path)[(0..limit)].join('')
      end
      lines
    end

    def where(row)
      return true if where_condition.nil?
      result = where_condition.all? do |col, match|
        row[col.to_s] == match.to_s
      end
      return false unless result
      true
    end

    def find(row)
      return true if find_condition.empty?
      result = find_condition.any? do |match|
        row['id'] == match.to_s
      end
      return false unless result
      true
    end

    def model
      @model ||= file_name_to_model
    end

    def open_csv
      File.open(@file_path).read.force_encoding('UTF-8')
    end

    def destroy_all(destroy_all_first)
      model.destroy_all if destroy_all_first
    end

    def delete_all(delete_all_first)
      model.delete_all if delete_all_first
    end

    def file_name_to_model
      file_name_from_path.classify.constantize
    end

    def file_name_from_path
      @file_path.split('/').last.split('.').first
    end

  end

end