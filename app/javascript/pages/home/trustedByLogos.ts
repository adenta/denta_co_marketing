export type TrustedByLogo = {
  name: string;
  label: string;
  src: string;
};

const logoModules = import.meta.glob("../../assets/home/trusted-by/*.{png,webp,jpeg,jpg}", {
  eager: true,
  import: "default",
  query: "?url",
}) as Record<string, string>;

function titleizeLogoName(name: string) {
  return name
    .split("-")
    .map(segment => segment.charAt(0).toUpperCase() + segment.slice(1))
    .join(" ");
}

export const trustedByLogos = Object.entries(logoModules)
  .map(([path, src]) => {
    const fileName = path.split("/").pop() ?? "";
    const name = fileName.replace(/\.(png|webp|jpeg|jpg)$/, "");

    return {
      name,
      label: titleizeLogoName(name),
      src,
    };
  })
  .sort((left, right) => left.name.localeCompare(right.name));
