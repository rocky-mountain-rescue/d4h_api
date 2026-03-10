# frozen_string_literal: true

module D4H
  module API
    class AttendanceResource < Resource
      SUB_URL = "attendance"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Attendance)
      end

      def list_all(**params)
        paginate_all(params, model_class: Attendance)
      end

      def show(id:)
        Attendance.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        Attendance.new(post_request(resource_url, body: data).body)
      end
    end
  end
end
