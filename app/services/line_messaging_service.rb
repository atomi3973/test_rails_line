require 'line-bot-api'

class LineMessagingService
  def initialize
    # 1. SDKのApiClientを初期化
    @client = Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV['LINE_MESSAGING_CHANNEL_TOKEN']
    )
  end

  def send_push_message(uid, text)
    return if uid.blank?

    # 2. 送信するメッセージのオブジェクトを作成
    # (生ハッシュではなく、SDKのクラスを使うのがv2流)
    message = Line::Bot::V2::MessagingApi::TextMessage.new(
      type: 'text',
      text: text
    )

    # 3. プッシュメッセージ用のリクエストを組み立てる
    push_request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: uid,
      messages: [message]
    )

    begin
      # 4. クライアントを通じて送信（APIエンドポイントURLを意識しなくて良くなる）
      @client.push_message(push_message_request: push_request)
      puts "✅ SDK経由で送信成功！"
    rescue Line::Bot::V2::MessagingApi::ApiError => e
      puts "❌ SDKエラー: #{e.message}"
      puts "詳細: #{e.response_body}"
    rescue => e
      puts "❌ 予期せぬエラー: #{e.message}"
    end
  end
end