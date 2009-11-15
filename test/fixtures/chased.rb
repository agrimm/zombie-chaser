class Chased
  def add(a,b)
    a + b
  end

  def say_hello
    "G'day!"
  end

  def self.static_method
    "Zap!"
  end

  def block_using_instance_method
    result = []
    block_yielding_instance_method do |i|
      result << i * 2
    end
    result
  end

  def block_yielding_instance_method
    yield 1
    yield 2
    yield 3
  end

  def self.block_using_class_method
    result = []
    block_yielding_class_method do |i|
      result << i * 2
    end
    result
  end

  def self.block_yielding_class_method
    yield 1
    yield 2
  end
end
