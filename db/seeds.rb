admin = User.find_or_initialize_by(employee_number: "0001")

admin.assign_attributes(
  name: "管理者",
  role: :admin,
  password: ENV.fetch("INITIAL_ADMIN_PASSWORD")
)

admin.save!

puts "Initial admin user is ready."
