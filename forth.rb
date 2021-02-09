class Forth
  class ProgramError < StandardError; end

  def self.run(src)
    new(src).run
  end

  def initialize(src)
    @src = src
    @stack = []
    @word = {}
  end

  def run
    @src.each_line do |line|
      @pc = 0
      @tokens = line.split(" ")
      while @tokens.size > @pc
        eval(@tokens[@pc])
        @pc += 1
      end
    end
  end

  private

  def eval(token)
    if !@word.include?(token) && token =~ /[0-9]+/
      push(token.to_i)
    elsif token == "+"
      y, x = pop, pop
      push(x + y)
    elsif token == "-"
      y, x = pop, pop
      push(x - y)
    elsif token == "*"
      y, x = pop, pop
      push(x * y)
    elsif token == "/"
      y, x = pop, pop
      push(x / y)
    elsif token == "MOD"
      y, x = pop, pop
      push(x % y)
    elsif token == "/MOD"
      y, x = pop, pop
      z = x % y
      a = x / y
      push(z)
      push(a)
    elsif token == "ABS"
      x = pop
      push(x.abs)
    elsif token == "NEGATE"
      x = pop
      push(-x)
    elsif token == "DROP"
      drop
    elsif token == "DUP"
      push(@stack[-1])
    elsif token == "NIP"
      nip
    elsif token == "SWAP"
      swap
    elsif token == "OVER"
      over
    elsif token == "ROT"
      rot
    elsif token == "2DROP"
      drop2
    elsif token == "2SWAP"
    elsif token == "2OVER"
    elsif token == "2DUP"
      dup2
    elsif token == "="
      y, x = pop, pop
      x == y ? push(-1) : push(0)
    elsif token == "<>"
      y, x = pop, pop
      x != y ? push(-1) : push(0)
    elsif token == "<"
      y, x = pop, pop
      x < y ? push(-1) : push(0)
    elsif token == ">"
      y, x = pop, pop
      x > y ? push(-1) : push(0)
    elsif token == "<="
      y, x = pop, pop
      x <= y ? push(-1) : push(0)
    elsif token == ">="
      y, x = pop, pop
      x >= y ? push(-1) : push(0)
    elsif token == "AND"
      push(pop & pop)
    elsif token == "OR"
      push(pop | pop)
    elsif token == "XOR"
      push(pop ^ pop)
    elsif token == ":"
      word = []
      @pc += 1
      word_name = @tokens[@pc]
      while true
        @pc += 1
        break if @tokens[@pc] == ";"
        word.push(@tokens[@pc])
        if @pc > @tokens.size
          raise ProgramError, "ワード定義 :に対応する;が見つかりません。"
        end
      end
      @word[word_name] = word
    elsif token == "."
      print "#{pop} "
    elsif token == "CR"
      puts ""
    elsif token == ".S"
      print ".S <#{@stack.size}> "
      @stack.map { |s| print "#{s} " }
    elsif token == "\\"
      @pc = @tokens.size
    elsif token == "("
      while true
        @pc += 1
        if @tokens[@pc] == ")"
          return
        end
        if @pc > @tokens.size
          raise ProgramError, "コメント (に対応する)が見つかりません。"
        end
      end
    elsif @word.include?(token)
      @tokens = [*@word[token], *@tokens.slice(@pc + 1, @tokens.size)]
      @pc = 0
      while @tokens.size > @pc
        eval(@tokens[@pc])
        @pc += 1
      end
    else
      raise ProgramError, "存在しない命令(#{token})です。"
    end
  end

  def pop
    item = @stack.pop
    raise ProgramError, "からのスタックをpopしようとしました。" if item.nil?
    item
  end

  def push(item)
    raise ProgramError, "数値以外をpushしようとしました。" unless item.is_a?(Integer)
    @stack.push(item)
  end

  def drop
    pop
  end

  def nip
    [*@stack.slice(0, @stack.size - 2), stack.slice(-1)]
  end

  def swap
    y, x = pop, pop
    push(y)
    push(x)
  end

  def over
    push(@stack[-2])
  end

  def rot
    push(@stack[-3])
  end

  def drop2
    pop; pop
  end

  def dup2
    push(@stack[-2])
    push(@stack[-2])
  end
end

if $0 == __FILE__
  if ARGV.size.zero?
    Forth.run(ARGF.read)
  else
    Forth.run(File.open(ARGV[0]).read)
  end
end
