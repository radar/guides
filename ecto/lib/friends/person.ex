defmodule Friends.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :first_name, :string
    field :last_name, :string
    field :age, :integer
  end

  def changeset(person, params \\ %{}) do
    person
    |> cast(params, ~w(first_name last_name age))
    |> validate_required([:first_name, :last_name])
  end
end
