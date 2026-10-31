module RatingsHelper
  # 4.0 shows as "4", 4.5 as "4.5".
  def format_score(score)
    number_with_precision(score, precision: 1, strip_insignificant_zeros: true)
  end

  def score_options
    Rating::SCORES.map { |score| [ format_score(score), score ] }
  end
end
