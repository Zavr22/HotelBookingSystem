# frozen_string_literal: true

require 'rails_helper'
module Mutations
  RSpec.describe CreateUser do
      let(:query) do
        <<~GQL
          mutation{
             createUser(input:{
               authProvider:{
                 credentials:{
                   login: "test",
                   password:"test",
                   role: "admin"
                 }
               }
             }){
               user{id}
               errorMessage
             }
           }
        GQL
      end

      subject(:result) do
        HotelSystemSchema.execute(query, context: nil).to_h
      end

      describe 'Create a new user' do
        it 'creates user' do
          expect(result['data']['createUser']['user']['id']).to eq(User.last.id.to_s)
        end
      end
    end
  end
