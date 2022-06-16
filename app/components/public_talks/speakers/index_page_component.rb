# frozen_string_literal: true

module PublicTalks
  module Speakers
    class IndexPageComponent < PageComponent
      attr_reader :speakers

      def initialize(speakers)
        @speakers = speakers
        setup_breadcrumb
      end

      def new_link
        link_to(t('app.links.new'), new_public_talks_speaker_path)
      end

      def edit_link(speaker)
        link_to(t('app.links.edit'), edit_public_talks_speaker_path(speaker))
      end

      def destroy_link(speaker)
        link_to(
          t('app.links.delete'), public_talks_speaker_path(speaker),
          data: { method: :delete, confirm: delete_confirmation(speaker) }
        )
      end

      def show_link(speaker)
        link_to(t('app.links.view'), public_talks_speaker_path(speaker))
      end

      private

      def delete_confirmation(speaker)
        t('app.messages.confirm_delete_x', record: speaker.name)
      end

      def setup_breadcrumb
        breadcrumb.add_item(t('app.links.public_speakers'))
      end
    end
  end
end
