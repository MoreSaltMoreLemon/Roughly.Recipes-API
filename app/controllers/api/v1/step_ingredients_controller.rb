class Api::V1::StepIngredientsController < ApplicationController
  # skip_before_action :authorized, only: [:index]
  before_action :find_step_ingredient, only: [:show, :edit, :update, :destroy]

  def index
    @step_ingredients = StepIngredient.all
    render json: @step_ingredients
  end

  def show
    # byebug
    render json: @step_ingredient, include: ['ingredient'], status: :accepted
  end

  def create
    # byebug
    @ingredient = Ingredient.find_or_create_by(name: step_ingredient_params[:ingredient][:name])
    @recipe_step = RecipeStep.find(step_ingredient_params[:recipe_step_id])
    if @recipe_step.step_ingredients.length == 0
      sequence_order = 0
    else
      sequence_order = @recipe_step.step_ingredients.max_by {|ri| ri.sequence_order}.sequence_order
    end
    # monstrosity used to get around Rails odd handling of errors when
    # creating a record. Cannot dirctly use strong params to create as it
    # needs the reference to the ingredient and nested params are garbage.
    @step_ingredient = StepIngredient.create(
      recipe_step_id: step_ingredient_params[:recipe_step_id],
      quantity: step_ingredient_params[:quantity] || 0,
      unit_id: step_ingredient_params[:unit_id] || 1,
      instruction: step_ingredient_params[:instruction] || '',
      color: step_ingredient_params[:color] || '#a6cee3',
      sequence_order: sequence_order + 1,
      is_sub_recipe: step_ingredient_params[:is_sub_recipe] || false,
      ingredient: @ingredient)
    if @step_ingredient.valid?
      render json: @step_ingredient, include: ['ingredient.*'], status: :created
    else
      render json: 
        { error: 'failed to create step_ingredient' }, 
        status: :not_acceptable
    end
  end

  def update
    # byebug
    @ingredient = Ingredient.find_or_create_by(name: step_ingredient_params[:ingredient][:name])
    # byebug
    # monstrosity used to get around Rails odd handling of errors when
    # creating a record. Cannot dirctly use strong params to create as it
    # needs the reference to the ingredient and nested params are garbage.
    @step_ingredient.update(
      recipe_step_id: step_ingredient_params[:recipe_step_id],
      quantity: step_ingredient_params[:quantity] || 0,
      unit_id: step_ingredient_params[:unit_id] || 1,
      instruction: step_ingredient_params[:instruction] || '',
      color: step_ingredient_params[:color] || '#a6cee3',
      sequence_order: step_ingredient_params[:sequence_order] || 0,
      is_sub_recipe: step_ingredient_params[:is_sub_recipe] || false,
      ingredient: @ingredient)
    # byebug
    if @step_ingredient.save
      render json: @step_ingredient, include: ['ingredient'], status: :accepted
    else
      render json: 
        { errors: @step_ingredient.errors_full_messages }, 
        status: :unprocessible_entity
    end
  end

  def destroy
    # byebug
    if @step_ingredient.destroy
      render json:
        { step_ingredient_destroyed: true },
        status: :accepted
    else 
      render json:
        { errors: @step_ingredient.errors_full_messages },
        status: :unprocessible_entity
    end
  end

  private

    def step_ingredient_params
      
      params.require(:step_ingredient).permit(:id, :recipe_step_id, :ingredient_id, :quantity, :unit_id, :instruction, :color, :sequence_order, :is_sub_recipe, ingredient: [:id, :name, :category_id])
    end

    def find_step_ingredient
      # byebug
      @step_ingredient = StepIngredient.find(params[:id])
    end
end
