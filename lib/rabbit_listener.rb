class RabbitListener
  def subscribe
    @connection = Bunny.new('amqp://guest:guest@rabbitmq', automatically_recover: true)
    @connection.start
    @channel = @connection.create_channel
    
    queue = @channel.queue('py_to_ruby', durable: true)
    
    queue.subscribe(manual_ack: true, block: true) do |delivery_info, properties, payload|
      begin
        process_message(payload)
        @channel.ack(delivery_info.delivery_tag)
      rescue => e
        Rails.logger.error "Error processing message: #{e.message}\n#{e.backtrace.join("\n")}"
        @channel.nack(delivery_info.delivery_tag, requeue: false)
      end
    end

  rescue Bunny::TCPConnectionFailed => e
    Rails.logger.error "RabbitMQ connection failed: #{e.message}"
    sleep 5
    retry
  end

  def process_message(payload)
    data = JSON.parse(payload)
    Rails.logger.debug "Received message: #{data}"
    user = User.find(data['user_id'].to_i)
    raise "User not found" unless user
    last_shot = { message_id: data['message_id'], gun_id: data['gun']['id'], gun_name: data['gun']['name']}
    old_params = user.parameters || {}
    user.update!(parameters: old_params.merge({last_shot: last_shot}))
  end

  def delete
    @connection.close
    super
  end
end

