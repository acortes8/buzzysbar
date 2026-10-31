# Shared rules for attached photos. Phones save HEIC by default, so it's
# accepted alongside the usual web formats; variants convert to JPEG so
# every browser can show them.
module PhotoAttachments
  extend ActiveSupport::Concern

  CONTENT_TYPES = %w[ image/jpeg image/png image/gif image/webp image/heic image/heif ].freeze
  MAX_SIZE = 25.megabytes

  class_methods do
    def photo_variants(attachable)
      attachable.variant :thumb, resize_to_fill: [ 400, 400 ], format: :jpeg
      attachable.variant :large, resize_to_limit: [ 1600, 1600 ], format: :jpeg
    end
  end

  private
    def validate_photo(attribute, attachment)
      if CONTENT_TYPES.exclude?(attachment.content_type)
        errors.add(attribute, "must be a JPEG, PNG, GIF, WebP, or HEIC image")
      elsif attachment.byte_size > MAX_SIZE
        errors.add(attribute, "must be smaller than #{MAX_SIZE / 1.megabyte} MB")
      end
    end
end
