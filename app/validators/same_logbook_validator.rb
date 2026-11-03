# Checks that an associated record is in the same logbook as the record, so an
# id sent from a form can't link in another logbook's place, drink or person.
#
#   validates :place, same_logbook: true
class SameLogbookValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && value.logbook_id != record.logbook_id
      record.errors.add(attribute, :same_logbook, message: "must be in the same logbook")
    end
  end
end
