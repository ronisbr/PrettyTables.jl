function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Int8})   # time: 0.120322414
    Base.precompile(Tuple{Core.kwftype(typeof(pretty_table)),NamedTuple{(:alignment, :crop), Tuple{Symbol, Symbol}},typeof(pretty_table),Vector{Any}})   # time: 0.06302529
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),AnsiTextCell})   # time: 0.04170598
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{Int8}})   # time: 0.03727323
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{UInt16}})   # time: 0.037094206
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{Float32}})   # time: 0.035648085
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{Int32}})   # time: 0.03363213
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Bool})   # time: 0.02969089
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{Char}})   # time: 0.026547253
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{UInt8}})   # time: 0.024201086
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{UInt32}})   # time: 0.02388679
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{Int8}})   # time: 0.02312287
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{Float16}})   # time: 0.022722742
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{UInt64}})   # time: 0.022702536
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{Int16}})   # time: 0.02242415
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{Bool}})   # time: 0.022153514
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{Float64}})   # time: 0.021576788
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{UInt8}})   # time: 0.021057334
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{Int64}})   # time: 0.019542322
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Tuple{Int64, Int64}})   # time: 0.016031398
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Int64})   # time: 0.015207979
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{Int16}})   # time: 0.014028797
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{UInt16}})   # time: 0.013717001
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{UInt32}})   # time: 0.013658639
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),String})   # time: 0.013646122
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{Bool}})   # time: 0.013268905
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{Float64}})   # time: 0.013160763
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{Char}})   # time: 0.013146092
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{String}})   # time: 0.013089693
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{Int32}})   # time: 0.012971524
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{UInt64}})   # time: 0.012969853
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{Float32}})   # time: 0.012962472
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{Float16}})   # time: 0.012928578
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Vector{String}})   # time: 0.012367174
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Matrix{Int64}})   # time: 0.012142053
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Int16})   # time: 0.011012898
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Symbol})   # time: 0.009962196
    Base.precompile(Tuple{typeof(_print_table_data!),Display,ProcessedTable,Matrix{Vector{String}},Vector{Int64},Int64,Vector{Int64},Symbol,Int64,Int64,Vector{Int64},NTuple{4, Char},Symbol,Int64,Ref{Any},Vector{Int64},TextFormat,Symbol,Crayon,Crayon,Crayon,Crayon,Crayon,Crayon,Crayon})   # time: 0.008835498
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Float32})   # time: 0.008666498
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Float16})   # time: 0.008663816
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Float64})   # time: 0.008628198
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),UInt16})   # time: 0.008624087
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Char})   # time: 0.008560861
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),UInt8})   # time: 0.008535831
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),UInt64})   # time: 0.008378167
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),UInt32})   # time: 0.008289684
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Int32})   # time: 0.008255657
    Base.precompile(Tuple{typeof(compact_type_str),DataType})   # time: 0.007673677
    Base.precompile(Tuple{typeof(_print_table_data!),Display,ProcessedTable,Matrix{Vector{String}},Vector{Int64},Int64,Vector{Int64},Symbol,Int64,Int64,Vector{Int64},NTuple{4, Char},Symbol,Int64,Ref{Any},Vector{Int64},TextFormat,Vector{Int64},Crayon,Crayon,Crayon,Crayon,Crayon,Crayon,Crayon})   # time: 0.005756214
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),Symbol})   # time: 0.004215688
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),String})   # time: 0.004116781
    Base.precompile(Tuple{Core.kwftype(typeof(_parse_cell_text)),NamedTuple{(:autowrap, :cell_data_type, :cell_first_line_only, :column_width, :compact_printing, :has_color, :limit_printing, :linebreaks, :renderer), Tuple{Bool, DataType, Bool, Int64, Bool, Bool, Bool, Bool, Val{:print}}},typeof(_parse_cell_text),URLTextCell})   # time: 0.002688719
    Base.precompile(Tuple{typeof(_process_data_cell_text),ProcessedTable,AnsiTextCell,String,Int64,Int64,Int64,Int64,Crayon,Symbol,Ref{Any}})   # time: 0.001787073
    Base.precompile(Tuple{typeof(_process_data_cell_text),ProcessedTable,URLTextCell,String,Int64,Int64,Int64,Int64,Crayon,Symbol,Ref{Any}})   # time: 0.001757811
    Base.precompile(Tuple{typeof(_print_custom_text_cell!),Display,AnsiTextCell,String,Crayon,Int64,Ref{Any}})   # time: 0.001235001
    Base.precompile(Tuple{typeof(_print_custom_text_cell!),Display,URLTextCell,String,Crayon,Int64,Ref{Any}})   # time: 0.001189596
end
