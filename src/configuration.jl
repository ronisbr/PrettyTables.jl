# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to handle the configuration objects of PrettyTables
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export pretty_table_with_conf, clear_pt_conf!, set_pt_conf, set_pt_conf!

################################################################################
#                                   Printing
################################################################################

"""
    pretty_table_with_conf(conf::PrettyTablesConf, args...; kwargs...)

Call `pretty_table` using the default configuration in `conf`. The `args...` and
`kwargs...` can be the same as those passed to `pretty_tables`. Notice that all
the configurations in `kwargs...` will overwrite the ones in `conf`.

The object `conf` can be created by the function `set_pt_conf` in which the
keyword parameters can be any one supported by the function `pretty_table` as
shown in the following.

"""
function pretty_table_with_conf(conf::PrettyTablesConf, args...; kwargs...)

    # Copy the configuration so that the user object is not modified.
    _local_conf = deepcopy(conf)

    # Apply the new configurations to it.
    set_pt_conf!(_local_conf; kwargs...)

    # Get the named tuple with the configurations.
    nt = _conf_to_nt(_local_conf)

    # Print the table.
    pretty_table(args...; nt...)
end

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
