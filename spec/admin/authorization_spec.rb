# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Authorization do
  subject(:acl) { described_class.new(request) }

  let(:user) { User.new }
  let(:params) { { controller: controller, action: action } }
  let(:request) { Struct.new(:params).new(params) }
  let(:controller) { 'foo_bar/baz' }
  let(:action) { 'index' }

  describe '#authorized?' do
    context 'when user is not authorized to that controller and action' do
      it 'returns false' do
        expect(acl).not_to be_authorized(user)
      end
    end

    context 'when user is authorized to the controller and action' do
      before do
        user.grant_controller_access(controller, action: action)
      end

      it 'returns true' do
        expect(acl).to be_authorized(user)
      end
    end

    context 'when user is authorized to the controller and all actions' do
      before do
        user.grant_controller_access(controller, action: '*')
      end

      it 'returns true' do
        expect(acl).to be_authorized(user)
      end
    end
  end
end
