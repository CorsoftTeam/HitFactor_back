class Club < ApplicationRecord
  validate :validate_time
  TIME_PARAMS = [:open_time_workday, :close_time_workday, :open_time_weekend, :close_time_weekend]

  def validate_time
    TIME_PARAMS.each do |time_key|
      time = self.send(time_key)
      return errors.add(time_key, 'формат времени должен быть 00:00') unless time.match?('\d\d:\d\d')
      hours, minuts = time.split(':').map { |t| t.to_i }
      return errors.add(time_key, 'число часов и минут должно быть валидно') unless 0 <= hours && hours < 24 && 0 <= minuts && minuts < 60
    end
  end
end
