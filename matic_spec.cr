require "spec"
require "./ponder"

describe Corp do
  describe ".parseFolder" do
    it "finds matching files in ./corpus and returns Corp objects with filename and body" do
      results = Corp.parseFolder("./corpus")

      results.should be_a(Array(Corp))
      results.size.should be > 0

      results[0].filename.should eq "./corpus/dracula.txt"
      results[1].filename.should eq "./corpus/frankenstein.txt"
      results[2].filename.should eq "./corpus/three_men_in_a_boat.txt"

      filenames = results.map(&.filename)
      bodies = results.map(&.body)

      filenames.any? { |f| f.includes?(".txt") }.should be_true

      bodies.any? { |b| b.includes?("Title: Three Men in a Boat") }.should be_true
      bodies.any? { |b| b.includes?("or, the Modern Prometheus") }.should be_true
      bodies.any? { |b| b.includes?("and he said it was called “paprika hendl,”") }.should be_true
    end
  end
end
