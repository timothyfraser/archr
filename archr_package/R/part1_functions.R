#' PART 1 FUNCTIONS
#' This script contains a series of functions that allow for stakeholder network analysis and supporting actions.
#' 
#' Some of these are internal functions, while others are functions intended to be used by actual R users.
#' If you encounter an issue with any of these functions, please tag it in a Github Issue.


#' @name get_nodes
#' @title Get nodes from edgelist or adjacency matrix
#' @author Tim Fraser
#' 
#' @param edges Optionally, an edgelist where the first column is `from` vertices and the second column is `to` vertices.
#' @param a Optionally, an adjacency matrix
#' 
#' @importFrom dplyr tibble
#' 
#' @export
get_nodes = function(edges = NULL, a = NULL){

  # If neither edgelist nor adjacency matrix is provided or valid
  if((is.null(edges) & is.null(a)) | (!is.data.frame(edges) & !is.matrix(a)) ){
    stop("Needs either valid `edges` data.frame or adjacency matrix `a`.")
  }

  # If an adjacency matrix is provided and valid
  if(!is.null(a) & is.matrix(a) ){

    # If both edges and matrix are supplied...
    if(is.data.frame(edges) & is.matrix(a)){
      print("`edges` and `a` both supplied. Defaulting to use `a`.")
    }

    # Get rownames and colnames from matrix. If missing, make integer.
    rownames = rownames(a); if(is.null(rownames)){ rownames = 1:nrow(a) }
    colnames = colnames(a); if(is.null(colnames)){ colnames = 1:ncol(a) }
    # Generate the nodes from the adjacency matrix
    nodes = dplyr::tibble(name = unique(c(rownames, colnames)))
    return(nodes)

    # If adjacency matrix is NOT provided, try edgelist
  }else{

    # If an edgelist is provided and it's a data.frame...
    if(!is.null(edges) & is.data.frame(edges)){
      # Generate the available nodes from the edgelist
      nodes = dplyr::tibble(name = unique(c(unlist(edges[,1]), unlist(edges[,2]))) )
      return(nodes)
    }

  }


}


#' @name get_edges
#' @title Get edgelist from adjacency matrix
#' @author Tim Fraser
#' 
#' @param a Adjaceny Matrix of n x n values, of `matrix` class in R. Optionally with column and row names.
#' 
#' @importFrom dplyr `%>%` as_tibble mutate filter
#' @importFrom tidyr pivot_longer
#' 
#' @export
get_edges = function(a = NULL){

  if(is.null(a)){ stop("Need valid adjacency matrix `a`, formatted as an R `matrix`") }
  # Get rownames and column names; if not present, make integers
  rownames = rownames(a); if(is.null(rownames)){ rownames = 1:nrow(a) }
  colnames = colnames(a); if(is.null(colnames)){ colnames = 1:ncol(a) }

  output = a %>%
    as_tibble() %>%
    # Rename columns
    setNames(nm = colnames) %>%
    # Rename rows
    mutate(from = rownames) %>%
    # Pivot longer
    pivot_longer(cols = -c(from), names_to = "to", values_to = "value") %>%
    # Filter out zeros or NAs
    filter(value != 0 | is.na(value))

  # If rownames were integer, make output$from integer
  if(is.integer(rownames)){ output$from = as.integer(output$from) }
  if(is.integer(colnames)){ output$to = as.integer(output$to) }

  # Return directed edgelist
  return(output)

}




#' @name get_adjacency
#' @title Convert an edgelist table to an adjacency matrix
#' @author Tim Fraser, PhD
#'
#' @param edges (data.frame) Requires a 'from' (character), 'to' (character), and 'value' column.
#' @param matrix (logical) TRUE/FALSE. By default, format = TRUE, so outputs a matrix; outputs a table if FALSE
#'
#' @description
#' By default, nodes is sourced from edges. (THIS MEANS WE'VE CENSORED ALL UNINVOLVED NODES.)
#'
#' @note We use `@importFrom` tags to mention function from external packages we need for this function, written like packagename function1 function2.
#' @importFrom tidyr pivot_wider
#' @importFrom dplyr select any_of
#' @importFrom magrittr set_rownames
#' @export
get_adjacency = function(edges, matrix = TRUE){

  # Testing values only
  # edges = readr::read_csv("workshops/test_edgelist.csv")

  # Get vector of all unique nodes in network
  # Derive nodelist from edgelist if no missing nodes

  nodes = unique(c(edges$from, edges$to))

  t = edges %>%
    #   pivot 'value' to be cells and 'to' to be column headers.
    #   Sum values of any multiple edges
    #   Set nodes
    tidyr::pivot_wider(
      # Use from column as left size
      id_cols = c(from),
      # Use to column as top
      names_from = to, values_from = value,
      # Aggregate by taking the sum
      values_fn = list(value = ~sum(.x, na.rm = TRUE))) %>%
    # Rearrange any nodes in order as character
    dplyr::select( from, dplyr::any_of(as.character(nodes)) ) %>%
    mutate(across(-c(from), .fns = ~if_else(is.na(.x), 0, .x)))


  if(matrix == TRUE){

    output = t %>%
      select(any_of(as.character(nodes))) %>%
      as.matrix() %>%
      magrittr::set_rownames(value = as.character(nodes))

  }else if(matrix == FALSE){

    output = t
  }else{ stop("---matrix should be TRUE or FALSE...")  }

  return(output)


}

#' @name get_graph
#' @title Get `igraph` Graph object 
#' @author Tim Fraser
#' @description 
#' Get an `igraph` formatted graph object 
#' from an adjacency matrix `a`, an `edges` edgelist,
#' or an `edges` edgelist and a `nodes` nodelist.
#' 
#' @param a Adjacency Matrix
#' @param edges Edgelist Data.frame with columns `from`, `to`, and `value`
#' @param nodes Nodelist Data.frame with column `name`
#' 
#' @importFrom igraph graph_from_adjacency_matrix graph_from_data_frame
#' 
#' @export
get_graph = function(a = NULL, edges = NULL, nodes = NULL){

  # If adjacency matrix is provided, default to that.
  if(!is.null(a) & is.matrix(a)){
    # Generate graph from adjacency matrix.
    # Keep directed, weighted, and use column names.
    # Keep diagonal, unless not needed.
    g = igraph::graph_from_adjacency_matrix(
      adjmatrix = a, mode = "directed",
      weighted = "value", diag = TRUE, add.colnames = "name")
    return(g)

  }else if(!is.null(edges) & is.data.frame(edges) & !is.null(nodes) & is.data.frame(nodes)){
    # Generate graph from edgelist and nodelist.
    # Keep directed. Use weights supplied in edges$`value`
    # Assumes edges has a `from`, `to`, and `value` column
    g = igraph::graph_from_data_frame(
      d = edges, directed = TRUE, vertices = nodes)
    return(g)
    # If you supply edges but not nodes,
  }else if(!is.null(edges) & is.data.frame(edges) & is.null(nodes) & !is.data.frame(nodes)){
    nodes = get_nodes(edges)
    # Generate the graph anyways
    g = igraph::graph_from_data_frame(
      d = edges, directed = TRUE, vertices = nodes)
    return(g)
    # Otherwise, give error
  }else{
    stop("Insufficient Inputs. Provide either `a` or both `edges` and `nodes`.")
  }

}

#' @name get_cycles
#' @title Get cycles in a graph
#' @author Tim Fraser
#' @description
#' Function to get all cycles in a graph starting and ending with a given root
#' 
#' @param g igraph directed graph object
#' @param root name of root vertex
#' @param cutoff Max length of simple paths to compute. Helpful for really big graphs.
#' @param vars A vector of 1 or more edge weight names from `g`. If `vars = NULL`, then skips edgewise edge weight computing.
#' 
#' @importFrom dplyr `%>%` tibble group_by reframe mutate n inner_join filter select bind_rows arrange ungroup lag lead
#' @importFrom igraph V is_igraph is_directed all_simple_paths neighbors get.edge.attribute get.edge.ids
#' @importFrom tidyr pivot_wider
#' 
#' @export
get_cycles = function(g = NULL, root = 1, cutoff = 50, vars = NULL){

  # Testing values
  # cutoff = 50
  # root = 3
  # vars = "value"
  # load("data/fakegraph.rda"); g = fakegraph; remove(fakegraph)
  # root = 'project'

  # Require a directed graph g
  if(!igraph::is_igraph(g)){ stop("`igraph` graph `g` required.") }
  if(!igraph::is_directed(g)){ stop("graph `g` must be **directed**") }
  # Extract nodes from g
  nodes = igraph::V(g)$name
  # If the root specified is not in the nodes,
  if(!root %in% nodes){  stop(paste0("root", " ", root, " is not in the nodelist for the inputs supplied.")) }

  # Get me all simple paths rooted at vertex 'root'
  # A path is simple if the vertices it visits are not visited more than once.
  # Evaluate up to path lengths of `cutoff` (let user change this)
  # Get simple paths going out from the root vertex
  p = igraph::all_simple_paths(g, from = root, mode = "out", cutoff = cutoff)

  n_p = length(p)

  # Get a tibble of all simple paths ##################################
  # As long as there are valid simple paths...
  if(n_p > 0){


    # Get a vector of unique pathid ids
    paths = dplyr::tibble(pathid = 1:n_p) %>%
      # For each path,
      dplyr::group_by(pathid) %>%
      # Get the vector of nodes in the path
      dplyr::reframe(nodeid = p[[pathid]] %>% as.vector() %>% nodes[.] ) %>%
      # For each path
      dplyr::group_by(pathid) %>%
      # List the order of that vertex in the path, from 1 to n
      dplyr::mutate(order = 1:n()) %>%
      dplyr::ungroup()

    # Generate a data.frame of all cycle ends, for any true cycle
    ends = paths %>%
      # For each path
      dplyr::group_by(pathid) %>%
      dplyr::reframe(
        # Get any vertices that the tail of the path reaches OUT to.
        # To find the tail of the paith, get the nodeid with the max order for that cycle.
        nodeid = igraph::neighbors(graph = g, v = nodeid[max(order)], mode = "out") %>%
          as.vector() %>% nodes[.],
        # Set the order of those nodes to be the NEXT number in the order
        order = max(order) + 1
      ) %>%
      # Filter to just end nodes which are the root
      dplyr::filter(nodeid %in% root) %>%
      dplyr::ungroup()

    n_ends = nrow(ends)
    if(n_ends > 0){
      ends = ends %>%
        # Add an ID for each of these valid cycle ends
        dplyr::mutate(cycleid = 1:n())

      # Generate a final data.frame of just cycles, eliminating all paths that do not return to the root.
      cycles = paths %>%
        # Narrow to just paths that end at the root, and bring that root's cycleid
        dplyr::inner_join(
          by = "pathid",
          y = ends %>% dplyr::select(pathid, cycleid)) %>%
        # Bind in the root ends
        dplyr::bind_rows(ends) %>%
        # Arrange Rows by cycleid, in order
        dplyr::arrange(cycleid, order) %>%
        # Rearrange columns
        dplyr::select(cycleid, nodeid, order)



      # If valid variables are supplied
      if(!is.null(vars)){
        # calculate the edgeweight value for each edge in every cycle

        cycle_edges = cycles %>%
          dplyr::group_by(cycleid) %>%
          dplyr::reframe(
            from = dplyr::lag(nodeid, 1, default = NA) %>% .[!is.na(.)],
            to = dplyr::lead(nodeid, 1, default = NA) %>% .[!is.na(.)]
          ) %>%
          # Assign an order id to all edges in each cycle
          dplyr::group_by(cycleid) %>%
          dplyr::mutate(order = 1:n()) %>%
          dplyr::ungroup() %>%
          # For each ro
          dplyr::rowwise() %>%
          dplyr::mutate(
            # Generate a matrix
            vp = list( matrix(c(from, to), ncol = 2, byrow = FALSE)),
            # Return the unique graph edge ids for each from-to pair
            edgeid = igraph::get.edge.ids(graph = g, vp = vp, directed = TRUE, multi = FALSE))%>%
          dplyr::ungroup()

        output = tibble(.var = vars) %>%
          # For as many edge important variables as supplied...
          dplyr::group_by(.var) %>%
          # Get a data.frame containing
          dplyr::reframe(
            # the original data, and...
            cycle_edges,
            # Get back the edge value
            value = igraph::edge_attr(graph = g, name = .var[1], index = edgeid)) %>%
          # Then pivot the result wider, to get one column for every edge metric queried.
          tidyr::pivot_wider(
            id_cols = c(cycleid, from, to, order, edgeid),
            names_from = .var, values_from = value) %>%
          # Arrange the result
          arrange(cycleid, order)

        return(output)

        # Otherwise, just return the cycles as the output
      }else{ output = cycles; return(output)  }

    }


  }else if(n_p == 0){
    # If no paths for that root, just return a blank tibble
    output = dplyr::tibble(); return(output)
  }


}

#' @name get_scores
#' @title Get Stakeholder Importance Scores
#' @description
#' Function to generate stakeholder important scores with regard to any project root.
#'
#' @param g igraph directed graph object
#' @param root node id for root (project node)
#' @param var variable for which to compute importance metrics
#' @param cutoff max path length to assess, to be passed to `get_cycles()`
#' @param square (logical) should you square the final edge that connects back to the project? Defaults to FALSE (no).
#'
#' @importFrom dplyr `%>%` tibble filter reframe mutate group_by ungroup rename summarize desc arrange
#' @importFrom igraph V
#'
#' @export
get_scores = function(g, root = 1, var = "value", cutoff = 50, square = FALSE){

  # Testing data
  # source("R/get_functions.R")
  # load("data/edges2.rda")
  # a = get_adjacency(edges2)
  # g = get_graph(a)
  # #load(file = "data/simgraph.rda"); g = simgraph
  # var = "value"
  # root = 1
  # cutoff = 50
  # root = "project"
  # square = FALSE


  nodes = igraph::V(g)$name

  # Generate data.frame of cycles, their edges, and their edge values
  allcycles = dplyr::tibble(rootid = nodes) %>%
    # Just the cycles that are root centric
    dplyr::filter(rootid %in% root) %>%
    # For each of those (usually just 1) roots
    dplyr::group_by(rootid) %>%
    # Get all cycles for that root
    dplyr::reframe(
      get_cycles(g = g, root = rootid, cutoff = cutoff, vars = var)
    )

    # Classify cycle edges as part of a project-centric cycle or not
    # all cycles rooted at 1, for example, have a rootid of 1

  if(nrow(allcycles) <= 1 & ncol(allcycles) <= 1){
    allcycles = tibble(
      .rows = 0,
      rootid = as.character(NA),
      cycleid = as.integer(NA),
      from = as.character(NA),
      to = as.character(NA),
      order = as.integer(NA),
      edgeid = as.double(NA),
      !!sym(var) := as.double(NA)
    )
  }

  # Find all stakeholder node IDs that are NOT the root.
  stakeholders = nodes[!nodes %in% root]

  # Get a frame of all cycles, for each stakeholder
  sh_grid = tibble(stakeholder = stakeholders) %>%
    group_by(stakeholder) %>%
    reframe(allcycles)

  sh_cycles = sh_grid %>%
    # For each stakeholder, take the data and...
    group_by(stakeholder) %>%
    # Get just root-centric cycles, whether they contain stakeholders or not
    filter(rootid %in% root) %>%
    # And for each stakeholder and the respective root
    group_by(stakeholder, rootid) %>%
    # Filter all cycle ids rooted at the rootid that contain stakeholder i
    filter(from == stakeholder[1] | to == stakeholder[1]) %>%
    # Record the unique cycleids
    reframe(cycleid = unique(cycleid),
            sh = TRUE)

  sh_grid2 = sh_grid %>%
    # Identify every root-centric cycle where,
    # for i in n stakeholders,
    # stakeholder i is present in that cycle
    left_join(by = c("rootid", "stakeholder", "cycleid"), y = sh_cycles) %>%
    # Name the specific importance metric '.y'
    dplyr::rename(.y = var)

  if(square == TRUE){
    # square the last value flow edge that links back to the project
    sh_grid2 = sh_grid2 %>%
      # For the given root, for each stakeholder, for each cycle
      dplyr::group_by(stakeholder, rootid, cycleid) %>%
      mutate(.y = case_when(
        # If it's the LAST item in the cycle, ending in the root,
        # square it to accentuate its value.
        to == rootid & order == max(order) ~ .y^2,
        TRUE ~ .y)) %>%
      ungroup()
  }

  sh_stats = bind_rows(
    # Get just the project-centric loops with stakeholder i
    sh_grid2 %>%
      filter(sh == TRUE) %>%
      mutate(group = "sh_i"),
    # Bind atop them all project-centric loops, with any stakeholders
    sh_grid2 %>% mutate(group = "total")
  ) %>%
    # For each cycle and group,
    group_by(stakeholder, rootid, cycleid, group) %>%
    # Calculate the cycle value flow score
    summarize(score = prod(.y, na.rm = TRUE),
              .groups = 'drop') %>%
    # Get the sum of cycle value flow scores for each group
    group_by(rootid, stakeholder, group) %>%
    summarize(sum = sum(score, na.rm = TRUE)) %>%
    # Split into to columns
    tidyr::pivot_wider(id_cols = c(rootid, stakeholder),
                       names_from = group, values_from = sum) %>%
    # Calculate important as the ratio of the two
    mutate(importance = sh_i / total) %>%
    # Calculate relative importance, as fraction of total importance
    group_by(rootid) %>%
    dplyr::mutate(relative = importance / sum(importance, na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    # Return stakeholders, sorted by relative importance
    dplyr::arrange(rootid, dplyr::desc(relative))

    return(sh_stats)

}

#' @name get_coords
#' @title Get Coordinates for Network Visual from igraph object
#' @description
#' Returns a list object include `nodes` and `edges`, which can be passed to `geom_point()` and `geom_curve()` respectively.
#'
#' @param g igraph graph object
#' @param layout ggraph-style character string layout option. Default is 'kk' for Kamada-Kawai layout
#' @param vars character vector of names of node traits from the igraph object to return
#'
#' @importFrom dplyr `%>%` select left_join any_of
#' @importFrom ggraph ggraph
#' @importFrom igraph as_data_frame
#'
#' @export
get_coords = function(g, layout = "kk", vars = "name"){
  #library(tidygraph)
  #library(igraph)
  #library(ggraph)
  #igraph::V(g)

  #vars = c("name")
  #layout = 'kk'

  # Get the node coordinates
  coords = g %>%
    ggraph::ggraph(layout = layout) %>%
    with(data) %>%
    dplyr::select(dplyr::any_of(c(vars, "x","y")))

  # Extract the vertices
  nodes = igraph::as_data_frame(g, what = "vertices") %>%
    # join in the coordinates
    dplyr::left_join(by = "name", y = coords)

  # Extract the edges
  edges = igraph::as_data_frame(g, what = "edges") %>%
    # join in coordinates
    dplyr::left_join(by = c("from" = "name"),
              y = coords %>% dplyr::select(name, from_x = x, from_y = y)) %>%
    # join in coordinates
    dplyr::left_join(by = c("to" = "name"),
              y = coords %>% dplyr::select(name, to_x = x, to_y = y))
  # Bind them together as a list
  output = list(nodes = nodes, edges = edges)
  return(output)
}



#' @name get_priority
#' @title Get Priority Measure for an AHP table
#' @author Tim Fraser, PhD
#'
#' @param data data.frame of pairwise comparisons of alternatives or criteria, formatted like `archr::pairs_alts` or `archr::pairs_criteria`
#' @param type "criteria" and/or "alt". Describes what kind of pairwise comparisons are provided in `data`. Use `c("criteria", "alt")` to get both.
#'
#' @importFrom dplyr `%>%` left_join group_by select summarize mutate rename ungroup any_of
#' @importFrom purrr map_dfr
#' 
#' @export
get_priority = function(data, type = "criteria"){

  # Testing Data
  # data = archr::pairs_alts
  # type = "alt"
  # data = archr::pairs_criteria
  # type = "criteria"

  get_priority_once = function(data, .type){

    if(.type == "criteria"){
      .group = c()
      .target = "criteria"
    }else if(.type == "alt"){
      .group = "criteria"
      .target = "alt"
    }else{ stop("Not a valid 'type' argument. Must be 'criteria' and/or 'alt'.") }

    # If the type column is included in your data,
    if(any(names(data) %in% "type")){
      # Filter to just that data type
      data = data %>% filter(type == .target)
    }

    # Get Named Groups
    .names = c(.group, .target)

    .groups = setNames(object = c(.group, "to"), nm = .names)


    # Next, we can normalize the data for each criteria
    # using the total value incurred by each recipient (`to`) -
    # the alternative we are comparing with respect `to`.

    # Here, we'll use `mutate()` with `group_by()`,
    # because for each group,
    # we want to just edit, not summarize, the rows,
    # returning the one sum for each group.
    # Then, we can calculate the `norm`alized value.

    p1 = data %>%
      group_by(across(.cols = any_of(.groups))) %>%
      summarize(total = sum(value, na.rm = TRUE))


    # Next, we can calculate the average normalized value of an alternative,
    # also known as the `priority` level of that alternative,
    # for each `criteria`.
    keywords = setNames(nm = .groups, object = names(.groups))

    # If p1 doesn't contain one of the keywords, skip it.
    keywords = keywords[ keywords %in% names(p1) ]

    .groups = setNames(object = c(.group, "from"), nm = .names)

    p2 = data %>%
      left_join(by = keywords, y = p1) %>%
      group_by(across(.cols = any_of(.groups))) %>%
      summarize(priority = mean(value / total, na.rm = TRUE))


    # Bind these stats together
    output = bind_rows(
      p1 %>% select(any_of(names(.groups)), value = total) %>% mutate(stat = "total"),
      p2 %>% select(any_of(names(.groups)), value = priority) %>% mutate(stat = "priority")
    ) %>%
      # Clarify the type of output
      mutate(type = .type)

    return(output)
  }

  # For each type supplied, run this loop.
  result = type %>% purrr::map_dfr(~get_priority_once(data = data, .type = .))

  return(result)

}


#' @name get_lambda
#' @title Get Lambda Statistic for an AHP table
#' @author Tim Fraser
#' 
#' @param data data.frame of output from `get_priority()`. Can handle priority statistics from a data.frame of priorities by alternatives, by criteria, or for both.
#' 
#' @importFrom tidyr pivot_wider
#' @importFrom dplyr `%>%` filter mutate left_join any_of group_by n summarize if_else tibble
#' 
#' @export
get_lambda = function(data){

  # People may not be consistent in their pairwise comparisons.
  # We can estimate consistency using a
  # consistency index and consistency ratio.
  # This requires making the statistic $\lambda_{max}$
  # for each pairwise comparison matrix,
  # by multiplying the recipient sums by the alternative priority levels,
  # for each criterion.


  mylambda = data %>%
    pivot_wider(id_cols = any_of(c("type", "criteria", "alt")), names_from = stat, values_from = value) %>%
    # If it's a criteria-style tabulation, set criteria to be 'goal'
    mutate(criteria = if_else(type == "criteria", true = "goal", false = criteria)) %>%
    group_by(criteria) %>%
    summarize(lambda_max = sum(priority * total),
              n = n())

  # Get random consistency index
  ri = tibble(
    n = 1:15,
    ri = c(0, 0, 0.58, 0.9, 1.12, 1.124, 1.32,
           1.41, 1.45, 1.49, 1.51, 1.53, 1.56, 1.57, 1.59))

  # Calculate your lambdas!
  lambdas = mylambda %>%
    # Calculate consistency index
    # conditional on sample size
    mutate(ci = (lambda_max - n) / (n - 1) ) %>%
    # Join in random consistency index
    left_join(by = c("n"), y = ri) %>%
    # Calculate consistency ratio
    mutate(cr = ci / ri)

  # View the lambdas!
  return(lambdas)

}



#' @name get_global
#' @title Get Global Measures for an AHP table
#' @author Tim Fraser
#'
#' @param data data.frame output from `get_priority()`, containing both alternatives and criteria.
#' @param format "wide" or "long". Describes output format of data.frame. Defaults to `"wide"`.
#' 
#' @importFrom dplyr `%>%` mutate select rename left_join bind_rows group_by across any_of ungroup arrange
#' @importFrom tidyr pivot_wider
#' 
#' @export
get_global = function(data, format = "wide"){

  # Finally, we can calculate the *global priority* of each alternative
  # with respect to the overall goal.

  # `priority_alt` represents the alternative's priority
  # with respect to a specific criterion (eg. tastiness).

  # `priority_cri` represents the criterion's priority
  # with respect to the overall goal.

  # `priority_global` is the product of the two,
  # which gives the Global Priority of this alternative
  # with respect to the Goal.

  alt = data %>%
    filter(stat == "priority") %>%
    filter(type == "alt") %>%
    select(criteria, alt, priority_alt = value)
  cri = data %>%
    filter(stat == "priority") %>%
    filter(type == "criteria") %>%
    select(criteria, priority_cri = value)

  t1 = left_join(
    x = alt,
    y = cri,
    by = c("criteria")) %>%
    mutate(priority_global = priority_alt * priority_cri)


  # Using these global priority statistics,
  # we can do a few final calculations.

  # First, we can, for each criterion,
  # get the total global priority.

  t2 = t1 %>%
    group_by(criteria) %>%
    summarize(
      alt = "total",
      priority_global = sum(priority_global))

  # Second, we can, for each alternative,
  # get the total global priority.

  t3 = t1 %>%
    group_by(alt) %>%
    summarize(
      criteria = "goal",
      priority_global = sum(priority_global))

  # Then, we can calculate the total global priority overall,
  # which should equal 1.

  t4 = t1 %>%
    ungroup() %>%
    summarize(
      alt = "total", criteria = "goal",
      priority_global = sum(priority_global))

  # Finally, we can bind the results together.

  # Make a final table of statistics
  tab = bind_rows(t1, t2, t3, t4) %>%
    select(criteria, alt, priority_global)

  # Make alt into a factor
  levels = c(sort(unique(tab$alt[ !tab$alt %in% "total"])), "total")
  tab = tab %>%
    mutate(alt = factor(alt, levels = levels)) %>%
    arrange(alt)

  if(format == "wide"){

    # And for good reporting,
    # we can pivot the output into a matrix.

    # Pivot the output into a matrix for easier reporting
    output = tab %>%
      pivot_wider(
        id_cols = c(alt),
        names_from = criteria,
        values_from = priority_global) %>%
      arrange(alt)
    return(output)

  }else if(format == "long"){
    output = tab
    return(output)

  }else{ stop("format must be 'long' or 'wide'.")}


}
#' @name get_ahp
#' @title Get Analytical Hierarchy Process Table
#' @author Tim Fraser, PhD
#' @description
#' Provide a table of alternatives and a table of criteria,
#' and this will return your AHP output table.
#'
#' @param alternatives data.frame of pairwise comparison of alternatives
#' @param criteria data.frame of pairwise comparison of criteria
#' @param format "wide" or "long". Describes output format of AHP table.
#'
#' @importFrom dplyr bind_rows
#'
#' @export
get_ahp = function(alternatives = archr::pairs_alts,
                   criteria = archr::pairs_criteria,
                   format = "wide"){

  # Get priority stats for pairwise comparisons of alternatives
  p_alt = get_priority(data = alternatives, type = "alt")
  # Get priority stats for pairwise comparisons of criteria
  p_cri = get_priority(data = criteria, type = "criteria")

  # Stack the priority statistics into one data.frame
  p = bind_rows(p_alt, p_cri)

  # Get lambda and consistency diagnostics
  lambda = get_lambda(data = p)

  # Get AHP global statistics table, in whatever format is requested
  tab = get_global(data = p, format = format)

  # Bind the two together into a list
  output = list(summary = tab, consistency = lambda)

  return(output)
}








