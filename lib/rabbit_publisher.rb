class RabbitPublisher
  def initialize
    @connection = Bunny.new(ENV['RABBITMQ_URL'] || 'amqp://guest:guest@rabbitmq')
    @connection.start
    @channel = @connection.create_channel
    @channel.confirm_select # Включаем подтверждение доставки

    @queue = @channel.queue('ruby_to_py', durable: true)
    @exchange = @channel.exchange(
      'ruby_to_py_exchange',
      type: :direct,
      durable: true
    )
    @queue.bind(@exchange, routing_key: @queue.name)

    Rails.logger.info "RabbitMQ publisher initialized"
  rescue => e
    Rails.logger.error "RabbitMQ connection error: #{e.message}"
    raise
  end

  def send_message(message)
    json_data = message.to_json
    Rails.logger.debug "Sending message: #{json_data}"

    @exchange.publish(
      json_data,
      routing_key: @queue.name,
      persistent: true,
    )

    if @channel.wait_for_confirms # Ожидаем подтверждения 5 секунд
      Rails.logger.info "Message confirmed"
    else
      Rails.logger.error "Message not confirmed!"
      raise "RabbitMQ message confirmation failed"
    end
  rescue => e
    Rails.logger.error "Error sending message: #{e.message}\n#{e.backtrace.join("\n")}"
    raise
  end

  def close
    @connection.close if @connection&.open?
  end
end