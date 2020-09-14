# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to handle the configuration objects of PrettyTables
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export clear_pt_conf!, set_pt_conf, set_pt_conf!

################################################################################
#                                   Printing
################################################################################

pretty_table(conf::PrettyTablesConf, ::Type{String}, data; kwargs...) =
    pretty_table(conf, String, data, []; kwargs...)

function pretty_table(conf::PrettyTablesConf,
                      ::Type{String},
                      data,
                      header::AbstractVecOrMat;
                      kwargs...)

    # Copy the configuration so that the user object is not modfied.
    _local_conf = deepcopy(conf)

    # Apply the new configurations to it.
    set_pt_conf!(_local_conf; kwargs...)

    # Get the named tuple with the configurations.
    nt = _conf_to_nt(_local_conf)

    # Print the table.
    pretty_table(String, data, header; nt...)
end

pretty_table(conf::PrettyTablesConf, data; kwargs...) =
    pretty_table(conf, stdout, data, []; kwargs...)

pretty_table(conf::PrettyTablesConf, data, header::AbstractVecOrMat; kwargs...) =
    pretty_table(conf, stdout, data, header; kwargs...)

pretty_table(conf::PrettyTablesConf, io::IO, data; kwargs...) =
    pretty_table(conf, io, data; kwargs...)

function pretty_table(conf::PrettyTablesConf,
                      io::IO,
                      data,
                      header::AbstractVecOrMat;
                      kwargs...)

    # Copy the configuration so that the user object is not modfied.
    _local_conf = deepcopy(conf)

    # Apply the new configurations to it.
    set_pt_conf!(_local_conf; kwargs...)

    # Get the named tuple with the configurations.
    nt = _conf_to_nt(_local_conf)

    # Print the table.
    pretty_table(io, data, header; nt...)
end

# Methods defined to avoid ambiguities.
pretty_table(conf::PrettyTablesConf, ::Type{String}, data::AbstractVecOrMat; kwargs...) =
    pretty_table(conf, String, data, []; kwargs...)

pretty_table(conf::PrettyTablesConf, io::IO, data::AbstractVecOrMat; kwargs...) =
    pretty_table(conf, io, data, []; kwargs...)

pretty_table(conf::PrettyTablesConf, data::AbstractVecOrMat; kwargs...) =
    pretty_table(conf, stdout, data, []; kwargs...)

################################################################################
#                                Set and clear
################################################################################

"""
    clear_pt_conf!(conf::PrettyTablesConf)

Clear all configurations in `conf`.

"""
function clear_pt_conf!(conf::PrettyTablesConf)
    empty!(conf.confs)
    return nothing
end

"""
    set_pt_conf(;kwargs...)

Create a new configuration object based on the arguments in `kwargs`.

"""
@inline function set_pt_conf(;kwargs...)
    conf = PrettyTablesConf()
    set_pt_conf!(conf; kwargs...)
    return conf
end

"""
    set_pt_conf!(conf; kwargs...)

Apply the configurations in `kwargs` to the object `conf`.

"""
@inline function set_pt_conf!(conf::PrettyTablesConf; kwargs...)
    for kw in kwargs
        conf.confs[kw[1]] = kw[2]
    end
    return nothing
end

################################################################################
#                              Private functions
################################################################################

"""
    _conf_to_nt(conf::PrettyTablesConf)

Convert the configuration object `conf` to a named tuple so that it can be
passed to `pretty_table`.

"""
@inline function _conf_to_nt(conf::PrettyTablesConf)
    # Get the named tuple with the configurations.
    dictkeys = (collect(keys(conf.confs))...,)
    dictvals = (collect(values(conf.confs))...,)
    nt = NamedTuple{dictkeys}(dictvals)
end
