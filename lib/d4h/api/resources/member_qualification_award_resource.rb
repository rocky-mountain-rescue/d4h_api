# frozen_string_literal: true

module D4H
  module API
    class MemberQualificationAwardResource < Resource
      SUB_URL = "member-qualification-awards"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: MemberQualificationAward)
      end

      def list_all(**params)
        paginate_all(params, model_class: MemberQualificationAward)
      end

      def create(data)
        MemberQualificationAward.new(post_request(resource_url, body: data).body)
      end
    end
  end
end
