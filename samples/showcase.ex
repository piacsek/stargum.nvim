# showcase.ex — syntax sampler for stargum.nvim screenshots
defmodule Stargum.Star do
  @moduledoc """
  A star with a hue and a set of spectral bands.
  Demonstrates structs, typespecs, guards, and pattern matching.
  """

  @enforce_keys [:id, :name, :hue]
  defstruct id: nil, name: "", hue: "#000000", spectra: [], pulsar?: false

  @type hue :: <<_::56>>
  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          hue: hue(),
          spectra: [String.t()],
          pulsar?: boolean()
        }

  @max_bands 64
  @default_hue "#ff6fc0"

  @doc "Build a star, falling back to the house bubblegum when no hue is given."
  @spec new(pos_integer(), String.t(), keyword()) :: t()
  def new(id, name, opts \\ []) when is_integer(id) and id > 0 do
    %__MODULE__{
      id: id,
      name: name,
      hue: Keyword.get(opts, :hue, @default_hue),
      spectra: opts |> Keyword.get(:spectra, []) |> Enum.take(@max_bands),
      pulsar?: Keyword.get(opts, :pulsar?, false)
    }
  end

  @doc "Pretty label, starring pulsars."
  @spec label(t()) :: String.t()
  def label(%__MODULE__{pulsar?: true, name: name}), do: "★ #{name}"
  def label(%__MODULE__{name: name}), do: name

  @doc "Sum the band count across a list of stars."
  @spec total_bands([t()]) :: non_neg_integer()
  def total_bands(stars) do
    stars
    |> Stream.map(&length(&1.spectra))
    |> Enum.reduce(0, fn count, acc -> acc + count end)
  end
end

defprotocol Shine do
  @doc "How brightly a thing shines, 0.0..1.0"
  def intensity(thing)
end

defimpl Shine, for: Stargum.Star do
  def intensity(%{pulsar?: true}), do: 1.0
  def intensity(%{spectra: spectra}) when length(spectra) > 8, do: 0.75
  def intensity(_star), do: 0.4
end

# A quick demo pipeline
stars = [
  Stargum.Star.new(1, "Bubblegum", hue: "#ff6fc0", spectra: ~w(core halo nebula)),
  Stargum.Star.new(2, "Cyan", pulsar?: true)
]

for star <- stars, intensity = Shine.intensity(star), intensity > 0.5 do
  IO.puts("#{Stargum.Star.label(star)} shines at #{intensity}")
end
