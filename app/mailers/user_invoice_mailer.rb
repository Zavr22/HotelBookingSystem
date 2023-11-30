class UserInvoiceMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def invoice_email(user)
    mail(to: user.login, subject: 'Invoice for your request was made')
  end
end
