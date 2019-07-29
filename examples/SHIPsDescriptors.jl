
module SHIPsDescriptors

using JuLIP, ASE, SHIPs, PyCall

"""
`SHIPDescriptor(; deg=nothing, wY=1.5, rcut=nothing, r0=1.0, p=2)`

This returns a `desc::SHIPBasis` object which can be interpreted as a descriptor
map. Call `descriptors(desc, py_at)` where `py_at` is a Python object
(of ase Atoms type) to get the descriptors.

Call `Dict(desc)` to obtain a dictionary that fully describes the descriptor
and can be serialised to a JSON file / deserialised.

* `bodyorder` : specify body-order; `bodyorder = 3` corresponds to SOAP??;
`bodyorder = 5` to SNAP??;
* `deg, wY` : specify polynomial degree restriction; the basis will contain all
tensor products `Pk * Ylm` such that `k + wY * l ≦ deg`.
* `rcut` : cutoff radius
* `r0` : an estimate for nearest-neighbour distance - not crucial
* `p` : specifies distance transform, u = (r/r0)^(-p); i.e., polynomials
`Pk` are polynomials in `u` not in `r`. (e.g. p = 1 => Coulomb coordinates)
"""
SHIPDescriptor(pyo::PyObject; bodyorder=3, deg=nothing, wY=1.5, rcut=nothing, r0=2.5, p=2, species=nothing) =
   SHIPDescriptor(ASEAtoms(pyo); bodyorder=bodyorder, deg=deg, wY=wY, rcut=rcut, r0=r0, p=p, species=species)

function SHIPDescriptor(aseat::ASEAtoms; bodyorder=3, deg=nothing, wY=1.5, rcut=nothing, r0=2.5, p=2, species=nothing)
   at = Atoms(aseat)
   trans = PolyTransform(p, r0)
   fcut = PolyCutoff1s(2, rcut)
   specs = unique(collect(chemical_symbols(at)))
   if species != nothing
        specs = species
   end
   return SHIPBasis(SparseSHIP(bodyorder-1, specs, deg, wY), trans, fcut)
end

HyperXSHIPDescriptor(pyo::PyObject; bodyorder=3, deg=nothing, wY=1.5, rcut=nothing, r0=2.5, p=2, species=nothing) =
   HyperXSHIPDescriptor(ASEAtoms(pyo); bodyorder=bodyorder, deg=deg, wY=wY, rcut=rcut, r0=r0, p=p, species=species)

function HyperXSHIPDescriptor(aseat::ASEAtoms; bodyorder=3, deg=nothing, wY=1.5, rcut=nothing, r0=2.5, p=2, species=nothing)
   at = Atoms(aseat)
   trans = PolyTransform(p, r0)
   fcut = PolyCutoff1s(2, rcut)
   specs = unique(collect(chemical_symbols(at)))
   if species != nothing
        specs = species
   end
   return SHIPBasis(HyperbolicCrossSHIP(bodyorder-1, specs, deg, wY), trans, fcut)
end


"""
`descriptors(basis::SHIPBasis, pyo::PyObject)`

If `pyo` is an `ase` `Atoms` object, then this returns a `Nx x Nat` matrix
where the i-th column is the descriptor vector for the neighbourhood of the
i-th atom.
"""
descriptors(basis::SHIPBasis, pyo::PyObject) =
   descriptors(basis, ASEAtoms(pyo))

function descriptors(basis::SHIPBasis, aseat::ASEAtoms)
   at = Atoms(aseat)
   B = zeros(Float64, length(basis), length(at))
   for i = 1:length(at)
      B[:, i] = site_energy(basis, at, i)
   end
   return B
end

end


# example code to test this:
# using ASE, SHIPs
# at = bulk("Si", cubic=true) * 2
# desc = SHIPsDescriptors.SHIPDescriptor(deg=6, rcut=4.0)
# B1 = SHIPsDescriptors.descriptors(desc, at)
# B2 = SHIPsDescriptors.descriptors(desc, at.po)
# B1 == B2
