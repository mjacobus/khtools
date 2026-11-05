# frozen_string_literal: true

module Finance
  class ArchiveJob < ApplicationJob
    def perform(document_id); end
  end
end
