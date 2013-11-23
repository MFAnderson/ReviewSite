class Feedback < ActiveRecord::Base
  attr_accessible :attitude_exceeded, :attitude_improve, :attitude_met, 
                  :client_exceeded, :client_improve, :client_met, 
                  :comments, 
                  :innovative_exceeded, :innovative_improve, :innovative_met, 
                  :leadership_exceeded, :leadership_improve, :leadership_met, 
                  :organizational_exceeded, :organizational_improve, :organizational_met, 
                  :ownership_exceeded, :ownership_improve, :ownership_met, 
                  :professionalism_exceeded, :professionalism_improve, :professionalism_met, 
                  :project_worked_on, 
                  :review_id, 
                  :role_description, 
                  :teamwork_exceeded, :teamwork_improve, :teamwork_met,
                  :tech_exceeded, :tech_improve, :tech_met, 
                  :role_competence_went_well, :role_competence_to_be_improved, :role_competence_action_items, :role_competence_scale,
                  :consulting_skills_went_well, :consulting_skills_to_be_improved, :consulting_skills_action_items, :consulting_skills_scale, 
                  :teamwork_went_well, :teamwork_to_be_improved, :teamwork_action_items, :teamwork_scale,
                  :contritubions_went_well, :contritubions_to_be_improved, :contritubions_action_items, :contritubions_scale, 
                  :user_id, :user_string

  validates :review_id, :presence => true
  validates :user_id, :presence => true

  validates :user_string, :presence => true, :unless => "user_string.nil?"

  validates :review_id, :uniqueness => {:scope => [:user_id, :user_string]}

  belongs_to :review
  belongs_to :user

  def reviewer
    if self.user_string.nil?
      self.user.name
    else
      self.user_string
    end
  end

  def submit_final
    update_attribute(:submitted, true)
    UserMailer.new_feedback_notification(self).deliver
  end

  def invitation
    review.invitations.each do |i|
      return i if i.user == user
    end
    nil
  end

  def is_additional
    not user_string.nil?
  end
end
