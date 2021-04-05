# frozen_string_literal: true

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe MarkdownHelper do

  context 'with parsing comment links' do
    it 'links to submission comments that exist' do
      com1 = create :comment, :submission_comment
      com2 = create :comment, :submission_comment, body: ">>#{com1.id}"
      parse_comment_links(com2.body)
      expect(com2.body).to eq("[\\>\\>#{com1.id}](/submissions/#{com1.source_id}##{com1.id})")
    end

    it 'links to thread comments that exist' do
      com1 = create :comment, :thread_comment
      com2 = create :comment, :submission_comment, body: ">>#{com1.id}"
      parse_comment_links(com2.body)
      expect(com2.body).to eq("[\\>\\>#{com1.id}](/forums/threads/#{com1.source_id}##{com1.id})")
    end

    it 'does not link to comments that do not exist' do
      com1 = create :comment, :submission_comment, body: '>>10000000000000000'
      parse_comment_links(com1.body)
      expect(com1.body).to eq('\\>\\>10000000000000000')
    end

    it 'does not link to comments that have been soft deleted' do
      com1 = create :comment, :submission_comment, :soft_deleted
      com2 = create :comment, :submission_comment, body: ">>#{com1.id}"
      parse_comment_links(com2.body)
      expect(com2.body).to eq("\\>\\>#{com1.id}")
    end

    it 'does not link to comments where the source has been deleted' do
      com1 = create :comment, :submission_comment, :soft_deleted
      Submission.find(com1.source_id).destroy!
      com2 = create :comment, :submission_comment, body: ">>#{com1.id}"
      parse_comment_links(com2.body)
      expect(com2.body).to eq("\\>\\>#{com1.id}")
    end

    it 'does not link to comments where the source has been soft deleted (submissions)' do
      com1 = create :comment, :submission_comment
      Submission.find(com1.source_id).update(soft_deleted: true, soft_deleted_by: User.first.id)
      com2 = create :comment, :submission_comment, body: ">>#{com1.id}"
      parse_comment_links(com2.body)
      expect(com2.body).to eq("\\>\\>#{com1.id}")
    end

    it 'does not link to comments where the source has not been approved (submissions)' do
      com1 = create :comment, :submission_comment
      Submission.find(com1.source_id).update(approved: false)
      com2 = create :comment, :submission_comment, body: ">>#{com1.id}"
      parse_comment_links(com2.body)
      expect(com2.body).to eq("\\>\\>#{com1.id}")
    end
  end

  context 'with challenge links' do
    it 'links to challenges that exist' do
      ch = create(:challenge)
      com = create :comment, :submission_comment, body: ">>C#{ch.id}"
      parse_challenge_links(com.body)
      expect(com.body).to eq("[\\>\\>C#{ch.id}](/challenges/#{ch.id})")
    end

    it 'does not link to challenges that do not exist' do
      com = create :comment, :submission_comment, body: '>>C100000000000000000000000000'
      parse_challenge_links(com.body)
      expect(com.body).to eq('\\>\\>C100000000000000000000000000')
    end

    it 'does not link to challenges that are soft deleted' do
      ch = create(:challenge)
      ch.update(soft_deleted: true, soft_deleted_by: User.first.id)
      com = create :comment, :submission_comment, body: ">>C#{ch.id}"
      parse_challenge_links(com.body)
      expect(com.body).to eq("\\>\\>C#{ch.id}")
    end
  end

  context 'with submission links' do
    it 'links to submissions that exist' do
      sub = create(:submission)
      com = create :comment, :submission_comment, body: ">>S#{sub.id}"
      parse_submission_links(com.body)
      expect(com.body).to eq("[\\>\\>S#{sub.id}](/submissions/#{sub.id})")
    end

    it 'does not link to submissions that do not exist' do
      com = create :comment, :submission_comment, body: '>>S100000000000000000000000000'
      parse_submission_links(com.body)
      expect(com.body).to eq('\\>\\>S100000000000000000000000000')
    end

    it 'does not link to submissions that are soft deleted' do
      sub = create(:submission)
      sub.update(soft_deleted: true, soft_deleted_by: User.first.id)
      com = create :comment, :submission_comment, body: ">>S#{sub.id}"
      parse_submission_links(com.body)
      expect(com.body).to eq("\\>\\>S#{sub.id}")
    end
  end

  context 'with quotes' do
    it 'doubles carriage return newlines' do
      com = create :comment, :submission_comment, body: "a\r\na"
      parse_quotes(com.body)
      expect(com.body).to eq("a\r\n\r\na")
    end

    it 'breaks up quotes not at the start of the line' do
      com = create :comment, :submission_comment, body: 'a >a'
      parse_quotes(com.body)
      expect(com.body).to eq('a \\>a')
    end

    it 'adds an extra > to display in the text' do
      com = create :comment, :submission_comment, body: '>a'
      parse_quotes(com.body)
      expect(com.body).to eq('>\\>a')
    end

    it 'breaks up multiple quotes' do
      com = create :comment, :submission_comment, body: '>>>a'
      parse_quotes(com.body)
      expect(com.body).to eq('>\\>\\>\\>a')
    end
  end

  context 'with hidden links' do
    before do
      ENV['DAD_DOMAIN'] = 'test.com'
    end

    after do
      ENV['DAD_DOMAIN'] = ''
    end

    it 'does not warn about internal markdown links' do
      com = create :comment, :submission_comment, body: "[link](http://#{ENV['DAD_DOMAIN']})"
      parse_external_links(com.body)
      expect(com.body).to eq("[link](http://#{ENV['DAD_DOMAIN']})")
    end

    it 'does warn about external markdown links' do
      com = create :comment, :submission_comment, body: '[link](https://google.com)'
      parse_external_links(com.body)
      expect(com.body)
        .to eq("[link](http://#{ENV['DAD_DOMAIN']}/leaving_dad?external_link=https://google.com)")
    end
  end
end
