# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::ObjectScript do
    let(:subject) { Rouge::Lexers::ObjectScript.new }
  
    describe 'guessing' do
      include Support::Guessing
  
      it 'guesses by filename' do
        assert_guess :filename => 'foo.cls'
      end
  
    end
  end
  