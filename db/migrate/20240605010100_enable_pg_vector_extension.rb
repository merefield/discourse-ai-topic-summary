# frozen_string_literal: true

class EnablePgVectorExtension < ActiveRecord::Migration[7.0]
  def change
    begin
      enable_extension :vector
    rescue Exception => e
      if DB.query_single("SELECT 1 FROM pg_available_extensions WHERE name = 'vector';").empty?
        STDERR.puts "------------------------------AI TOPIC SUMMARY ERROR----------------------------------"
        STDERR.puts "      AI Topic Summary requires the pgvector extension on the PostgreSQL database."
        STDERR.puts "         Run a `./launcher rebuild app` to fix it on a standard install."
        STDERR.puts "            Alternatively, you can remove AI Topic Summary to rebuild."
        STDERR.puts "------------------------------AI TOPIC SUMMARY ERROR----------------------------------"
      end
      raise e
    end
  end
end