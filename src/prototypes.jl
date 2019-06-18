

function eval_basis end
function eval_basis! end
function eval_grad end
function eval_basis_d! end

eval_basis(B, args...) =
   eval_basis!(alloc_B(B), B, args...)
eval_basis_d(B, args...) =
   eval_basis_d!(alloc_B(B), alloc_dB(B), B, args...)

function alloc_B end
function alloc_dB end

function transform end
function transform_d end
function fcut end
function fcut_d end