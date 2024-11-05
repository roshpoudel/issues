defmodule Issues.TableFormatter do
  import Enum, only: [each: 2, map: 2, map_join: 3, max: 1]

  @doc """
  Prints a table for the given rows and headers.

  ## Parameters
  - rows: A list of maps representing the rows of the table.
  - headers: A list of strings representing the headers of the table.
  """
  @spec print_table_for_columns(list(map()), list(String.t())) :: :ok
  def print_table_for_columns(rows, headers) do
    with data_by_columns = split_into_columns(rows, headers),
         column_widths = widths_of(data_by_columns),
         format = format_for(column_widths) do
      puts_one_line_in_columns(headers, format)
      IO.puts(separator(column_widths))
      puts_in_columns(data_by_columns, format)
    end
  end

  @doc """
  Splits the rows into columns based on the headers.

  ## Parameters
  - rows: A list of maps representing the rows of the table.
  - headers: A list of strings representing the headers of the table.

  ## Returns
  A list of lists, where each inner list represents a column.
  """
  @spec split_into_columns(list(map()), list(String.t())) :: list(list(String.t()))
  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(row[header])
    end
  end

  @doc """
  Converts a value to a printable string.

  ## Parameters
  - str: The value to be converted.

  ## Returns
  The printable string representation of the value.
  """
  @spec printable(any()) :: String.t()
  def printable(str) when is_binary(str), do: str
  def printable(str), do: to_string(str)

  @doc """
  Calculates the widths of each column.

  ## Parameters
  - columns: A list of lists, where each inner list represents a column.

  ## Returns
  A list of integers representing the width of each column.
  """
  @spec widths_of(list(list(String.t()))) :: list(integer())
  def widths_of(columns) do
    for column <- columns, do: column |> map(&String.length/1) |> max
  end

  @doc """
  Generates the format string for the given column widths.

  ## Parameters
  - column_widths: A list of integers representing the width of each column.

  ## Returns
  The format string for the columns.
  """
  @spec format_for(list(integer())) :: String.t()
  def format_for(column_widths) do
    map_join(column_widths, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end

  @doc """
  Generates the separator string for the given column widths.

  ## Parameters
  - column_widths: A list of integers representing the width of each column.

  ## Returns
  The separator string for the columns.
  """
  @spec separator(list(integer())) :: String.t()
  def separator(column_widths) do
    map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end

  @doc """
  Prints the data in columns using the given format.

  ## Parameters
  - data_by_columns: A list of lists, where each inner list represents a column.
  - format: The format string for the columns.
  """
  @spec puts_in_columns(list(list(String.t())), String.t()) :: :ok
  def puts_in_columns(data_by_columns, format) do
    data_by_columns
    |> List.zip()
    |> map(&Tuple.to_list/1)
    |> each(&puts_one_line_in_columns(&1, format))
  end

  @doc """
  Prints one line of fields in columns using the given format.

  ## Parameters
  - fields: A list of strings representing the fields to be printed.
  - format: The format string for the columns.
  """
  @spec puts_one_line_in_columns(list(String.t()), String.t()) :: :ok
  def puts_one_line_in_columns(fields, format) do
    :io.format(format, fields)
  end
end
