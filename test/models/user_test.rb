require 'test_helper'

class UserTest < ActiveSupport::TestCase
    def setup
        @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
    end

    #VALID CASE

    test "should be valid" do
        assert @user.valid?
    end

    test "email validation should accept valid addresses" do
        valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
        valid_addresses.each do |valid_address|
            @user.email = valid_address
            assert @user.valid?, "#{valid_address.inspect} should be valid"
        end
    end

    #INVALID INPUTS
    #name

    test "name should be present" do
        @user.name = "    "
        assert_not @user.valid?
    end

    test "name should not be too long" do
        @user.name = "a" * 51
        assert_not @user.valid?
    end

    test "name should not contain excess whitespace" do
        @user.name = "Example  User"
        assert_not @user.valid?
    end

    test "name should not contain preceding whitespace" do
        @user.name = " Example User"
        assert_not @user.valid?
    end

    test "name should not contain appended whitespace" do
        @user.name = "Example User "
        assert_not @user.valid?
    end

    #email

    test "email should be present" do
        @user.email = "    "
        assert_not @user.valid?
    end

    test "email should not be too long" do
        @user.email = "a" * 244 + "@example.com"
        assert_not @user.valid?
    end

    test "email validation should reject invalid addresses" do
        invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
        invalid_addresses.each do |invalid_address|
            @user.email = invalid_address
            assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
        end
    end

    #password

    test "password should be present (nonblank) " do
        @user.password = @user.password_confirmation = " " * 6
        assert_not @user.valid?
    end

    test "password should have a minimum length" do
        @user.password = @user.password_confirmation = "a" * 5
        assert_not @user.valid?
    end

    test "password should have a maximum length" do
        @user.password = @user.password_confirmation = "a" * 51
        assert_not @user.valid?
    end

    #UNIQUENESS

    test "names should be unique" do
        duplicate_user = @user.dup
        duplicate_user.name = @user.name.upcase
        duplicate_user.email = "a" + @user.email
        @user.save
        assert_not duplicate_user.valid?
    end

    test "email addresses should be unique" do
        duplicate_user = @user.dup
        duplicate_user.name = @user.name + "a"
        duplicate_user.email = @user.email.upcase
        @user.save
        assert_not duplicate_user.valid?
    end

end
