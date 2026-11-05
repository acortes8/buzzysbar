# Occasion photos were attached straight to occasions (has_many_attached), which
# leaves nowhere to mark one published. This gives each one a Photo record and
# points its existing attachment there, so no files are copied. Every moved
# photo starts unpublished.
class MoveOccasionPhotosToPhotos < ActiveRecord::Migration[8.1]
  def up
    select_rows(<<~SQL).each do |attachment_id, occasion_id, created_at|
      SELECT id, record_id, created_at FROM active_storage_attachments
      WHERE record_type = 'Occasion' AND name = 'photos'
    SQL
      photo_id = select_value(<<~SQL)
        INSERT INTO photos (occasion_id, published, created_at, updated_at)
        VALUES (#{quote(occasion_id)}, false, #{quote(created_at)}, #{quote(created_at)})
        RETURNING id
      SQL
      execute <<~SQL
        UPDATE active_storage_attachments
        SET record_type = 'Photo', record_id = #{quote(photo_id)}, name = 'image'
        WHERE id = #{quote(attachment_id)}
      SQL
    end
  end

  def down
    execute <<~SQL
      UPDATE active_storage_attachments
      SET record_type = 'Occasion', record_id = photos.occasion_id, name = 'photos'
      FROM photos
      WHERE active_storage_attachments.record_type = 'Photo' AND active_storage_attachments.record_id = photos.id
    SQL
    execute "DELETE FROM photos"
  end
end
