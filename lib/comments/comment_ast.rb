# frozen_string_literal: true

class CommentAst
  # A catamorphism.
  def fold(f)
    f.call(map { |x| x.fold(f) })
  end
end

class CommentChildren < CommentAst
  attr_accessor :children

  def initialize(children)
    super
    @children = children
  end

  def map(f)
    CommentChildren.new(@children.map(f))
  end
end

class Paragraph < CommentAst
  attr_accessor :child

end

class CommentText < CommentASt
  attr_accessor :text

  def initialize(text)
    super
    @text = text
  end

  def map(_); end
end

class CommentReply < CommentASt
  attr_accessor :subject

  def initialize(subject)
    super
    @subject = subject
  end

  def map(_); end
end

class CommentQuote < CommentASt
  attr_accessor :child

  def initialize(child)
    super
    @child = child
  end

  def map(f)
    CommentQuote.new(f.call(@child))
  end
end

class CommentItalic < CommentASt
  attr_accessor :child

  def initialize(child)
    super
    @child = child
  end

  def map(f)
    CommentQuote.new(f.call(@child))
  end
end

class CommentBold < CommentASt
  attr_accessor :child

  def initialize(child)
    super
    @child = child
  end

  def map(f)
    CommentQuote.new(f.call(@child))
  end
end
