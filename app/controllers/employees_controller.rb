class EmployeesController < ApplicationController
	skip_before_action :verify_authenticity_token
	def create
	    employee = Employee.new(employee_params)

	    if employee.save
	      render json: { message: "Employee created successfully.", employee: employee }, status: :created
	    else
	      render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
	    end
	end

	def tax_deduction
	  employee = Employee.find(params[:id])

	  # Calculate total salary for the financial year
	  current_year = Date.today.year
	  financial_year_start = Date.new(current_year, 4, 1)
	  financial_year_end = Date.new(current_year + 1, 3, 31)

	  doj = employee.doj
	  months_worked = 0

	  if doj <= financial_year_end
	    first_month_days = doj > financial_year_start ? 30 - doj.day : 0
	    months_worked = [(12 - first_month_days / 30).ceil, 12].min
	  end

	  monthly_salary = employee.salary
	  yearly_salary = (monthly_salary * months_worked).to_i
	  tax, cess = calculate_tax_and_cess(yearly_salary)

	  render json: {
	    employee_id: employee.employee_id,
	    first_name: employee.first_name,
	    last_name: employee.last_name,
	    yearly_salary: yearly_salary,
	    tax_amount: tax,
	    cess_amount: cess
	  }, status: :ok
	end

	private

	def employee_params
	    params.require(:employee).permit(:employee_id, :first_name, :last_name, :email, :doj, :salary, phone_numbers: [])
	end

	def calculate_tax_and_cess(yearly_salary)
	  tax = 0

	  if yearly_salary > 250_000
	    taxable_salary = yearly_salary - 250_000
	    if taxable_salary <= 250_000
	      tax += taxable_salary * 0.05
	    elsif taxable_salary <= 500_000
	      tax += (250_000 * 0.05) + ((taxable_salary - 250_000) * 0.1)
	    elsif taxable_salary <= 1_000_000
	      tax += (250_000 * 0.05) + (500_000 * 0.1) + ((taxable_salary - 500_000) * 0.2)
	    else
	      tax += (250_000 * 0.05) + (500_000 * 0.1) + (500_000 * 0.2) + ((taxable_salary - 1_000_000) * 0.2)
	    end
	  end

	  cess = yearly_salary > 2_500_000 ? (yearly_salary - 2_500_000) * 0.02 : 0

	  [tax.to_i, cess.to_i]
	end
end
