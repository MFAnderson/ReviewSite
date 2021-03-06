require 'spec_helper'

describe AssociateConsultant do
  before do
    user = create(:user, name: "Example User")
    coach = create(:user)
    @ac = build(:associate_consultant, :coach => coach, :user => user)
  end

  subject { @ac }
  it{ @ac.to_s.should == "Example User" }

  it{ should respond_to(:notes)}
  it{ should respond_to(:reviewing_group_id)}
  it{ should respond_to(:coach_id)}

  describe "has associations" do
    it { should belong_to(:user) }
  end

  describe "#can_graduate?" do
    let(:review) { create(:twenty_four_month_review) }
    let(:reviews) { [review] }
    it "returns true when graduation date has passed" do
      ac = create(:associate_consultant, reviews: reviews)
      ac.can_graduate?.should be_true
    end

    it "returns false when graduation date has not passed" do
      ac = create(:associate_consultant)
      ac.can_graduate?.should == false
    end

    it "returns false when an AC has already graduated" do
      ac = create(:associate_consultant, :has_graduated)
      ac.can_graduate?.should == false
    end
  end

  it "can have a reviewing group" do
    @ac.reviewing_group = create(:reviewing_group)
    @ac.valid?.should == true
  end

  it "shouldn't be valid with invalid coach id" do
    @ac.coach_id = "some"
    @ac.valid?.should == false
  end

  it "shouldn't be valid with invalid reviewing group" do
    @ac.reviewing_group = nil
    @ac.valid?.should == false
    @ac.errors[:reviewing_group_id].should include("can't be blank.")
  end

  it "should be valid with valid coach id" do
    @ac.coach_id = 1
    @ac.valid?.should == true
  end

  describe "with reviews" do
    let(:associate_consultant) { create(:associate_consultant) }
    let!(:six_month_review) { create(:six_month_review, :associate_consultant => associate_consultant) }

    it "should delete the review when the associate consultant is deleted" do
      Review.all.count.should == 1
      associate_consultant.destroy
      Review.all.count.should == 0
    end

    describe "#upcoming_review" do
      describe "should return only the future review closest to today" do
        let(:twelve_month_review)   { create(:twelve_month_review, associate_consultant: associate_consultant) }
        let(:eighteen_month_review) { create(:eighteen_month_review, associate_consultant: associate_consultant) }

        subject { associate_consultant }
        
        its(:upcoming_review) { should == six_month_review }
      end
    end
  end
end
