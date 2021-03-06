module Tanker
  module Utilities
    class << self
      def get_model_classes
        Tanker.included_in ? Tanker.included_in : []
      end

      def get_available_indexes
        get_model_classes.map{|model| model.index_name}.uniq.compact
      end

      def clear_all_indexes
        get_available_indexes.each do |index_name|
          begin
            index = Tanker.api.get_index(index_name)

            if index.exists?
              puts "Deleting #{index_name} index"
              index.delete_index()
            end
            puts "Creating #{index_name} index"
            index.create_index()
            puts "Waiting for the index to be ready"
            while not index.running?
              sleep 0.5
            end
          rescue => e
            puts "There was an error clearing or creating the #{index_name} index: #{e.to_s}"
          end
        end
      end

      def reindex_all_models
        get_model_classes.each do |klass|
          puts "Indexing #{klass.to_s} model"
          klass.all.each do |model_instance|
            model_instance.update_tank_indexes
          end
        end
      end
    end
  end
end

