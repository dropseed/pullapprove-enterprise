export const colors = {
  success: "success",
  error: "danger",
  failure: "danger",
  approved: "success",
  pending: "secondary",
  rejected: "danger",
  unavailable: "muted",
  true: "success",
  false: "danger",
};

export function textColor(key) {
  return "text-" + colors[key];
}
