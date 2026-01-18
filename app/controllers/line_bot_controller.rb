require 'line-bot-api'

class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    parser = Line::Bot::V2::WebhookParser.new(
      channel_secret: ENV['LINE_MESSAGING_CHANNEL_SECRET']
    )

    begin
      events = parser.parse(body: body, signature: signature)
    rescue Line::Bot::V2::WebhookParser::InvalidSignatureError
      render plain: "Bad Request", status: 400
      return
    end

    # --- 【ここから追加】クライアントの準備 ---
    client = Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV['LINE_MESSAGING_CHANNEL_TOKEN']
    )
    # ---------------------------------------

    events.each do |event|
      if event.is_a?(Line::Bot::V2::Webhook::MessageEvent)
        if event.message.is_a?(Line::Bot::V2::Webhook::TextMessageContent)
          
          # --- 【ここから追加】返信の作成と実行 ---
          
          # 1. 送信したいメッセージオブジェクトを作る
          message = Line::Bot::V2::MessagingApi::TextMessage.new(
            text: "おうむ返しです！：「#{event.message.text}」"
          )
          
          # 2. 返信リクエスト（誰に、何を）を組み立てる
          reply_request = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
            reply_token: event.reply_token,
            messages: [message]
          )
          
          # 3. 実行！
          client.reply_message(reply_message_request: reply_request)
          
          # ---------------------------------------
          
          puts "✅ 返信を送信しました: #{event.message.text}"
        end
      end
    end

    render plain: "OK"
  end
end