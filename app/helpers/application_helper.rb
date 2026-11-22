module ApplicationHelper
  # Classes for a form field, marked as an error when the attribute has one:
  #   form.text_field :name, class: input_class(person, :name)
  def input_class(record, attribute, *extra)
    [ "input", *extra, { "input-error" => record.errors[attribute].any? } ]
  end

  # A nav link, marked as the current page anywhere in its section of the
  # site. Takes link_to's arguments, with or without a block.
  def nav_link_to(*args, current: nil, **options, &block)
    path = block ? args.first : args.second
    current = request.path.start_with?(path) if current.nil?
    link_to(*args, **options, aria: { current: ("page" if current) }, &block)
  end
end
