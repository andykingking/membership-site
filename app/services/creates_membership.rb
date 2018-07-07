class CreatesMembership
  include ActiveModel::Model

  attr_accessor :user
  attr_accessor :plan
  attr_accessor :card_token

  def call
    stripe_customer = Stripe::Customer.create \
      email: user.email,
      description: "User ##{user.id}",
      card: card_token

    stripe_customer.subscriptions.create(plan: plan.id)

    create_customer_and_membership stripe_customer.id, stripe_customer.default_card
  end

  def create_customer_and_membership(stripe_id = nil, stripe_card_id = nil)
    customer = Customer.create! \
      user_id: user.id,
      stripe_id: stripe_id,
      stripe_card_id: stripe_card_id

    Membership.create!(customer_id: customer.id, plan_id: plan.id)

    MembershipCreatedMailer.create(user.id).deliver_now
    MembershipCreatedMailer.notify(user.id).deliver_now
  end
end
